# express-mle-javascript

Example how to use node-express with MLE/JavaScript

## Database Setup

You require an Oracle Database Free instance. The easiest way to create one is to use the container images provided by Oracle. Make sure not to use the `-slim` images, these don't come with Multilingual Engine/MLE.

Here's an example compose file you can use as the starting point.

>The instructions in the readme refer to rootless `podman`, adapt as necessary for other container runtimes like Docker.

```yaml
# THIS IS NOT A PRODUCTION SETUP - LAB USE ONLY!
services:
    oracle:
        image: docker.io/gvenzl/oracle-free:23.6
        ports:
            - 1521:1521
        environment:
            - ORACLE_PASSWORD_FILE=/run/secrets/oracle-passwd
        volumes:
            - oradata-vol:/opt/oracle/oradata
        networks:
            - backend
        healthcheck:
            test: [ "CMD", "healthcheck.sh" ]
            interval: 10s
            timeout: 5s
            retries: 10
            start_period: 5s
        secrets:
            - oracle-passwd

volumes:
    oradata-vol:

networks:
    backend:

secrets:
    oracle-passwd:
        external: true
```

The file worked brilliantly with `podman-compose 1.0.6-1` and `podman 4.9.3`. Make sure you defined a podman secret named `oracle-passwd` before bringing the database up.

### Application User

Once the database is up and running (visible in the output of `podman logs <container>`) you need to set up an application user as follows in `FREEPDB1`.

The easiest way to do that is via [SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/). Either install it locally or use the [official image](https://container-registry.oracle.com/ords/ocr/ba/database/sqlcl). The latter is preferable if you don't want to deal with SQLcl's dependencies.

1. Get required connection information

    Before starting you need to know

    - the name of the database container to connect to
    - the network it used

    Use the following snippet to get the container name
    ```sh
    podman ps --format "{{.Image}} --> use {{.Names}}"
    docker.io/gvenzl/oracle-free:23.6 --> use dbfree_oracle_1
    ```

    Similarly, use `podman network ls` to get the network. Let's assume the network name is `dbfree_backend`.

1. Start SQLcl

    Don't forget to update the network name!

    ```
    cd express-mle-javascript/src/

    podman run -it --rm \
    --volume ./database/:/opt/oracle/sql_scripts:Z \
    --network dbfree_backend \
    container-registry.oracle.com/database/sqlcl:latest /nolog
    ```

    This will launch SQLcl.

1. Connect to the SYSTEM account using the container name you worked out earlier

    ```sql
    connect system@dbfree_oracle_1/freepdb1
    ```

1. Next switch to the Pluggable Database and create the user

    ```sql
    alter session set container = FREEPDB1;

    create user app_user identified by "someSecretPasswordOfYourLiking"
    default tablespace users
    quota 1g on users;

    grant execute on javascript to app_user;
    grant execute dynamic MLE to app_user;
    grant db_developer_role to app_user;
    grant soda_app to app_user;

    alter user app_user default role all;
    ```

## Code deployment

Connect as the newly created user and run the `deploy.sql` script:

```
connect app_user@dbfree_oracle_1/freepdb1
start deploy.sql
```

You should see the deployment on your screen:

```
SQL> start deploy
MLE Module demo_module created

Table DEMO_TABLE created.


Procedure PROCESS_DATA compiled


Function GET_DB_DETAILS compiled


Function GET_MESSAGE_BY_ID compiled
```

## Start the application

Open a new terminal and start the express application as follows:

```sh
cd ./express-mle-javascript
npm i
npm run dev
```

## Have fun!

Test the application by posting a message to the database

```sh
curl -X POST -H "Content-Type: application/json" \
-d '{"message": "this message has been provided via curl"}' \
http://localhost:3000
```

Retrieve messages from the database, subsituting the ID with the primary key from the table.

```sh
curl http://localhost:3000/1
```