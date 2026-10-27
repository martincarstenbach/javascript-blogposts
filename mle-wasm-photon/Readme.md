# Image processing with Photon WASM in Oracle AI Database

This proof of concept runs [Photon](https://github.com/silvia-odwyer/photon), a Rust image-processing library compiled to WebAssembly, inside Oracle AI Database's Multilingual Engine (MLE). It stores uploaded images as BLOBs and exposes inspection and resizing through Oracle REST Data Services (ORDS).

The example targets Autonomous AI Database 26ai with WebAssembly support introduced in RU 23.26.4. See the [Oracle announcement](https://blogs.oracle.com/developers/whats-new-in-mle-23-26-4-webassembly-lands-in-oracle-ai-database) for availability details. Photon is pinned to version **0.3.3**.

**This is a demonstration, not a production-ready image upload service.** Outstanding validation and resource-management requirements are described below and in the JavaScript module's JSDoc.

## How it works

The request path is:

```text
HTTP request with bearer token
  → ORDS handler (PL/SQL or SQL)
  → photon_api PL/SQL call specification
  → photon_utilities MLE JavaScript
  → Photon JavaScript bindings and WASM module
  → uploaded_files table
```

The `photon_env` MLE environment maps the imports to their database modules. JavaScript initializes Photon with the imported WASM module and calls its bindings. Oracle MLE provides the `session`, `oracledb`, and `OracleBlob` globals used for database access.

The JavaScript functions leave transaction control to the caller. The upload and resize REST handlers commit successful inserts.

## Repository files

| File | Purpose |
| --- | --- |
| [01_wasm_staging_table.sql](01_wasm_staging_table.sql) | Creates the `wasm_modules` staging table. |
| [02_stage_photon.sh](02_stage_photon.sh) | Downloads Photon artifacts and loads them with SQL*Loader. |
| [load_photon.ctl](load_photon.ctl) | Loads the JavaScript and WASM files into BLOB columns. |
| [03_create_module_and_env.sql](03_create_module_and_env.sql) | Creates the MLE modules, environment, and `photon_api` PL/SQL package. |
| [04_ords_upload.sql](04_ords_upload.sql) | Creates `uploaded_files` and the upload endpoint. |
| [05_ords_photon_api.sql](05_ords_photon_api.sql) | Creates the details and resize endpoints. |
| [06_ords_security.sql](06_ords_security.sql) | Creates the OAuth client, role, and privilege, then publishes both ORDS modules. |
| [env_example](env_example) | Template for local SQL*Loader connection settings. |

## Prerequisites

- An Oracle database deployment with MLE WebAssembly support enabled.
- A REST-enabled application schema and its ORDS schema base URL.
- Schema permissions to create the demo's tables, MLE modules and environment, PL/SQL package, ORDS resources, and OAuth client, and to execute the MLE code. Have the database administrator provision the required permissions. If you use a playground, or local dev environment, consider the `DB_DEVELOPER_ROLE` to get started quickly. Don't use it in higher tier environments!
- SQLcl or another compatible Oracle SQL script client.
- SQL*Loader and an Oracle client configured for the database connection.
- Bash and `curl`; outbound HTTPS access to `cdn.jsdelivr.net` for the Photon download.
- For an Autonomous Database mTLS connection, a configured wallet and network access to the database endpoint. See [Oracle's wallet connection instructions](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/connect-prepare-oci-wallets.html).

Run all setup scripts from the repository root, using the same application schema. Schema creation, REST enablement, and database privileges are not provisioned by these scripts.

## Set up the demo

### 1. Prepare local connection settings

```bash
cp env_example .env
chmod 600 .env
```

Edit `.env` locally and supply `ORACLE_USERNAME`, `ORACLE_PASSWORD`, and `ORACLE_CONNECTIONSTRING`. For mTLS, follow the wallet notes in `env_example`, including `TNS_ADMIN` and the wallet location in `sqlnet.ora`.

The staging script sources `.env` as shell code, so use a trusted local file. `.env`, `stage/`, `logs/`, and `tns/` are ignored by Git. Keep credentials and wallet files out of commits; keep any wallet stored elsewhere outside the repository as well.

### 2. Create the staging table

Connect to the application schema with SQLcl. For example, use an Oracle Net service alias and enter the password when prompted:

```text
sql /nolog
connect your_db_account@your_service_alias
```

Then run:

```sql
@01_wasm_staging_table.sql
```

### 3. Download and load Photon

In a shell, from the repository root:

```bash
bash 02_stage_photon.sh
```

The script downloads `photon_rs.js` and `photon_rs_bg.wasm`, then invokes SQL*Loader. Check the loader output and its timestamped log in `logs/`. The staging table should contain two rows:

```sql
select
    module_name,
    module_version,
    dbms_lob.getlength(module_blob) as bytes
from
    wasm_modules
order by
    module_name;
```

The loader uses `APPEND`; rerunning it against the populated staging table conflicts with its primary key, resulting in `.bad` files.

### 4. Create the implementation and REST endpoints

In the connected SQL session:

```sql
@03_create_module_and_env.sql
@04_ords_upload.sql
@05_ords_photon_api.sql
```

The ORDS modules remain unpublished until security is configured in the following step.

### 5. Configure OAuth and publish the endpoints

Review `06_ords_security.sql` and customize its placeholder support contact.

Run the script in a session whose output is not captured in shared logs:

```sql
@06_ords_security.sql
```

It creates:

- Role: `photon_api_role`
- Privilege: `photon.api.privilege`, covering both REST modules
- OAuth client: `photon_api_client`, using the client credentials grant

The script prints the client ID and newly generated secret. Store them securely. If the secret is lost, rotate it; the commented rotation example in the script needs its client name changed to `photon_api_client`.

## Call the REST API

Set the schema base URL, without a trailing slash:

```bash
ORDS_BASE_URL='https://your-host/ords/your-schema-alias'
CLIENT_ID='your-client-id'
```

### Obtain a bearer token

```bash
curl --fail-with-body --user "$CLIENT_ID" \
  --data 'grant_type=client_credentials' \
  "$ORDS_BASE_URL/oauth/token"
```

`curl` prompts for the client secret as the password. The JSON response contains an `access_token`. Enter that value into a shell variable without displaying it or putting the value directly in a command:

```bash
printf 'Access token: '
IFS= read -r -s ACCESS_TOKEN
printf '\n'
```

This is client authentication, not per-user photo ownership. A client granted the demo role can access the protected photo operations for other rows as well.

### Upload an image

```bash
curl --fail-with-body --include \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Content-Type: image/jpeg' \
  --data-binary '@photo.jpg' \
  "$ORDS_BASE_URL/uploads/photo.jpg"
```

Send the encoded image as the raw request body, not as a multipart form. Use the MIME type matching your file. The handler declares JPEG, PNG, BMP, ICO, TIFF, and WebP MIME types; actual decoding depends on the supplied Photon build and image variant.

On success, upload returns **HTTP 201**. It currently returns neither the inserted ID nor a `Location` header. Find the row in SQL and use its ID for subsequent requests:

```sql
select id, filename, content_type, uploaded_at
from uploaded_files
order by id desc;
```

For the following examples, replace `1` with that ID:

```bash
PHOTO_ID=1
```

### Inspect a photo

```bash
curl --fail-with-body \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  "$ORDS_BASE_URL/photon/photos/$PHOTO_ID"
```

The GET handler returns JSON with dimensions, pixel count, encoded and decoded sizes, transparency, grayscale detection, and average RGB values. Color depth describes Photon's decoded RGBA8 pixels, not the original encoding. These are pixel statistics, not EXIF metadata.

### Resize a photo

```bash
curl --fail-with-body --include --request POST \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  "$ORDS_BASE_URL/photon/photos/$PHOTO_ID/resize"
```

The operation creates a new PNG at half the original width and height using Lanczos3 sampling. Odd dimensions round down, with a minimum of one pixel per dimension. The source remains unchanged. Halving both dimensions gives approximately one-quarter of the pixels; it does not guarantee a particular encoded file size.

On success, the response is **HTTP 201** with `{"id": }`. The stored filename is `photo__resized.png`. The current resize handler accepts IDs from 1 through 1,000,000,000. It returns 400 for invalid IDs, 404 for a missing source, and a generic 500 for other processing failures.

There is no image-download endpoint in this example.

## Call from SQL and PL/SQL

The ID parameters are strings:

```sql
select json_serialize(photon_api.photo_details('1') pretty) as photo_details;
```

For resizing, use a PL/SQL block because the function inserts a row:

```sql
set serveroutput on
declare
    l_new_id number;
begin
    l_new_id := photon_api.resize_photo('1');
    commit;
    dbms_output.put_line('Resized photo ID: ' || l_new_id);
exception
    when others then
        rollback;
        raise;
end;
/
```

## PoC limitations and production TODOs

The current validation deliberately remains simple:

- All three JavaScript entry points reject empty BLOBs and encoded files over **10 MiB** before reading their contents.
- Upload and resize enforce **16 million pixels after decoding**. The decoder may already have allocated a large raster before rejection.
- `photoDetails()` currently has **no pixel limit** and copies the decoded RGBA array into JavaScript. A 16-megapixel RGBA8 array alone occupies 64,000,000 bytes, in addition to WASM and decoder allocations.
- Upload stores the caller-supplied MIME type without verifying it against the image format. MIME restrictions do not establish that content is safe.

Before production use, address the module's outstanding TODOs: validate encoded dimensions before decoding, retain post-decode checks in every entry point, reject malformed or unsupported variants, and verify format/MIME consistency. Define memory, execution-time, concurrency, and storage limits appropriate to the deployment. Dimension checks alone are not a total memory bound.

The demo also lacks per-photo ownership controls and a uniform HTTP error contract. The staging script passes the database password in SQL*Loader's command-line connection string; assess credential handling before using it in a shared environment. Downloads are version-pinned but the script does not verify artifact checksums.

The JavaScript module includes JSDoc describing the functions and these limitations. The scripts and HTTP examples should be validated in your target database and ORDS environment; this README does not imply that deployment has been tested there.