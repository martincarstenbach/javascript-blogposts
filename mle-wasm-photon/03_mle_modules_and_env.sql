-- load the JavaScript bindings
create or replace mle module photon 
language javascript
using blob
    select
        module_blob
    from
        wasm_modules
    where
        module_name = 'photon_rs.js'
        and module_version = '0.3.3';
/

-- followed by the actual Web Assembly module
create or replace mle module photon_wasm
language wasm
using blob
    select
        module_blob
    from
        wasm_modules
    where
        module_name = 'photon_rs_bg.wasm'
        and module_version = '0.3.3';
/

-- finally add some logic to it!
create or replace mle module photon_utilities
language javascript
version '0.2.0' as

import source photonWasm from "photon_wasm";
import * as photon from "photon";

/**
 * Proof-of-concept photo helpers for Oracle MLE with Photon WASM.
 * Photon and its WASM module are imported above; Oracle MLE supplies the global
 * session, oracledb and OracleBlob objects.
 * Database writes participate in the caller's transaction; no helper commits.
 *
 * This example demonstrates in-database image processing and is not production
 * ready. All three functions reject encoded BLOBs larger than 10 MiB before
 * reading them. Upload and resize enforce 16 megapixels only after decoding;
 * photoDetails() currently has no pixel limit. These checks do not bound peak
 * decoder memory use, and a small compressed image may expand significantly.
 *
 * Outstanding production-readiness TODOs:
 * - Validate dimensions before decoding in every entry point, rejecting malformed
 *   headers and unsupported variants. Retain a post-decode dimension check.
 * - Add the missing pixel limit in photoDetails() before get_raw_pixels() copies
 *   the RGBA array into JavaScript. At 16 megapixels that array alone is 64 MB
 *   (64,000,000 bytes); WASM images and decoder buffers require additional memory.
 * - Identify the format from file content and verify the declared MIME type
 *   before storing it. A MIME declaration alone does not validate the bytes.
 *
 * Pre-decode dimension checks are one layer of protection; production deployment
 * also needs appropriate memory, execution-time and concurrency limits.
 * @file
 */

// Limits for encoded BLOB bytes and decoded width multiplied by height.
// A small compressed file can still expand to a very large decoded raster.
const maxBytes = 10 * 1024 * 1024; // 10 MiB = 10,485,760 bytes
const maxPixels = 16000000;        // 16 megapixels


/**
 * Validates and inserts an image into uploaded_files.
 * Enforces a 10 MiB BLOB limit before decoding and a 16 megapixel limit
 * after decoding. Stores the original bytes; the caller owns the transaction.
 *
 * @todo For production, validate dimensions before decoding to reduce exposure
 *   to oversized rasters; the current pixel check happens after allocation.
 * @todo Verify the MIME type against the file content before storing metadata.
 *
 * @param {string} filename - Filename to store with the uploaded image.
 * @param {?string} content_type - Declared MIME type; a falsy value defaults
 *   to application/octet-stream. This value does not identify the image format.
 * @param {OracleBlob} content - Nonempty Oracle BLOB containing an encoded image.
 * @returns {void}
 * @throws {Error} If the BLOB is empty, a limit is exceeded, decoding fails,
 *   or the database insert fails.
 */
export function saveUploadedFile(filename, content_type, content) {

    if (content === null || content === undefined) {
        throw new Error(`The uploaded file ${filename} is empty`);
    }
    const size = content.length();
    if (size === 0) {
        throw new Error(`The uploaded file ${filename} is empty`);
    }
    // Reject before copying the BLOB into JavaScript or decoding the image.
    if (size > maxBytes) {
        throw new Error(`The uploaded file ${filename} exceeds the 10 MiB size limit`);
    }

    photon.initSync({ module: photonWasm });
    const image = photon.PhotonImage.new_from_byteslice(content.getData());
    try {
        // Production TODO: validate encoded dimensions before the decode above.
        // This check rejects oversized results only after WASM has allocated them.
        const width = image.get_width();
        const height = image.get_height();
        if (width * height > maxPixels) {
            throw new Error(`The uploaded image ${filename} exceeds the 16 megapixel limit`);
        }

    } finally {
        image.free();
    }

    // Insert only after both limits and image decoding have succeeded.
    session.execute(
        `insert into uploaded_files set filename = :filename, content_type = :content_type, file_content = :content`,
        {
            filename: filename,
            content_type: content_type || "application/octet-stream",
            content: {
                dir: oracledb.BIND_IN,
                type: oracledb.ORACLE_BLOB,
                val: content
            }
        }
    );
}

/**
 * @typedef {Object} PhotoDetails
 * @property {number} width - Decoded width in pixels.
 * @property {number} height - Decoded height in pixels.
 * @property {number} aspect_ratio - Width divided by height.
 * @property {"square"|"landscape"|"portrait"} orientation - Shape of the image.
 * @property {number} pixel_count - Width multiplied by height.
 * @property {number} megapixels - Pixel count divided by 1,000,000.
 * @property {number} file_size_bytes - Encoded BLOB size in bytes.
 * @property {number} decoded_size_bytes - Size of the decoded RGBA pixel array.
 * @property {"RGBA"} color_model - Photon's decoded color model.
 * @property {number} channels - Four decoded color channels.
 * @property {number} bits_per_channel - Eight bits per decoded channel.
 * @property {number} bits_per_pixel - Thirty-two bits per decoded pixel.
 * @property {boolean} has_transparency - Whether any pixel has alpha below 255.
 * @property {boolean} is_grayscale - Whether every pixel has equal RGB values.
 * @property {{red: number, green: number, blue: number}} average_rgb - Arithmetic
 *   mean of each RGB channel (0–255), including transparent pixels.
 */

/**
 * Looks up a photo by primary key and returns and logs its decoded statistics.
 * Statistics describe Photon's RGBA8 pixels, not the source encoding's color
 * depth or metadata. Releases the decoded WASM image before returning.
 *
 * The 10 MiB encoded BLOB limit is enforced before reading; no pixel limit is
 * currently enforced by this PoC function.
 *
 * @todo For production, validate dimensions before decoding and enforce the
 *   pixel limit again before get_raw_pixels() allocates the JavaScript copy.
 *
 * @param {string} id - uploaded_files ID represented as a string that converts
 *   to a positive JavaScript safe integer. ORDS provides variables as strings!
 * @returns {PhotoDetails} Decoded dimensions, sizes, color and pixel statistics.
 * @throws {Error} If the ID is invalid, the row is missing, the BLOB is empty,
 *   or database access, validation or decoding fails.
 */
export function photoDetails(id) {

    if (typeof id !== "string" || !/^\d+$/.test(id.trim())) {
        throw new Error("photoDetails() requires a positive integer ID as a string");
    }

    // A safe integer avoids precision loss when binding the JavaScript number.
    const numericId = Number(id.trim());
    if (!Number.isSafeInteger(numericId) || numericId <= 0) {
        throw new Error("photoDetails() requires an ID greater than zero within the safe integer range");
    }

    // read the photo (blob) from the database
    const result = session.execute(
        "select file_content from uploaded_files where id = :id",
        { id: { val: numericId, dir: oracledb.BIND_IN, type: oracledb.NUMBER } }
    );

    if (result.rows.length === 0) {
        throw new Error(`No photo found for ID ${id}`);
    }

    const photoBlob = result.rows[0].FILE_CONTENT;
    if (photoBlob === null || photoBlob === undefined) {
        throw new Error(`The photo BLOB with id ${id} is empty`);
    }

    const size = photoBlob.length();
    if (size === 0) {
        throw new Error(`The photo BLOB with id ${id} is empty`);
    }

    if (size > maxBytes) {
        throw new Error(
            `The photo with id ${id} exceeds the 10 MiB size limit`
        );
    }

    // Copy the encoded image into JavaScript only after checking its size.
    const bytes = photoBlob.getData();
    if (bytes.length === 0) {
        throw new Error(`The photo BLOB with id ${id} is empty`);
    }

    // this is where the WebAssembly module is initialised. The following JavaScript
    // code calls the JS bindings, not Wasm directly. You can find the documentation
    // here: https://docs.rs/photon-rs/latest/photon_rs/index.html
    photon.initSync({ module: photonWasm });
    const image = photon.PhotonImage.new_from_byteslice(bytes);

    // Production TODO: validate dimensions before the decode above, then enforce
    // the 16 megapixel limit again before get_raw_pixels(). The PoC does neither.

    try {
        const width = image.get_width();
        const height = image.get_height();
        // Copies RGBA8 pixels out of WASM; source bit depth is not retained.
        const pixels = image.get_raw_pixels();
        const pixelCount = width * height;
        let hasTransparency = false;
        let isGrayscale = true;
        let red = 0;
        let green = 0;
        let blue = 0;

        // Each pixel occupies four consecutive bytes: red, green, blue, alpha.
        for (let i = 0; i < pixels.length; i += 4) {
            red += pixels[i];
            green += pixels[i + 1];
            blue += pixels[i + 2];
            if (pixels[i + 3] < 255) hasTransparency = true;
            if (pixels[i] !== pixels[i + 1] || pixels[i] !== pixels[i + 2]) {
                isGrayscale = false;
            }
        }

        const details = {
            width,
            height,
            aspect_ratio: width / height,
            orientation: width === height ? "square" : width > height ? "landscape" : "portrait",
            pixel_count: pixelCount,
            megapixels: pixelCount / 1000000,
            file_size_bytes: bytes.length,
            decoded_size_bytes: pixels.length,
            color_model: "RGBA",
            channels: 4,
            bits_per_channel: 8,
            bits_per_pixel: 32,
            has_transparency: hasTransparency,
            is_grayscale: isGrayscale,
            // Arithmetic mean of all decoded pixels, including transparent ones.
            average_rgb: {
                red: red / pixelCount,
                green: green / pixelCount,
                blue: blue / pixelCount
            }
        };

        // Emits derived image statistics to the host's JavaScript log output.
        console.log(JSON.stringify(details, null, 2));
        return details;
    } finally {
        image.free();
    }
};

/**
 * Inserts a new PNG at half the source width and height and returns its ID.
 * Odd dimensions round down, with a minimum of one pixel per dimension.
 * Uses Lanczos3 sampling and preserves transparency. Enforces a 10 MiB source
 * BLOB limit before decoding and a 16 megapixel limit after decoding.
 * Releases temporary BLOB and WASM resources; the caller owns the transaction.
 *
 * @todo For production, validate source dimensions before decoding. The current
 *   post-decode pixel check bounds resizing work, not the decoder's allocations.
 *
 * @param {string} id - uploaded_files source ID as a positive decimal integer
 *   string within JavaScript's safe integer range; surrounding whitespace is allowed.
 * @returns {number} Primary key of the inserted photo_<id>_resized.png row.
 * @throws {Error} If the ID is invalid, the source is missing or empty, a limit
 *   is exceeded, or database access, decoding, resizing or encoding fails.
 */
export function resizePhoto(id) {
    if (typeof id !== "string" || !/^\d+$/.test(id.trim())) {
        throw new Error("resizePhoto() requires a positive integer ID as a string");
    }

    // A safe integer avoids precision loss when binding the JavaScript number.
    const numericId = Number(id.trim());
    if (!Number.isSafeInteger(numericId) || numericId <= 0) {
        throw new Error("resizePhoto() requires an ID greater than zero within the safe integer range");
    }

    const source = session.execute(
        "select file_content from uploaded_files where id = :id",
        { id: { val: numericId, dir: oracledb.BIND_IN, type: oracledb.NUMBER } }
    );

    if (source.rows.length === 0) {
        throw new Error(`No photo found for ID ${numericId}`);
    }

    const sourceBlob = source.rows[0].FILE_CONTENT;
    if (sourceBlob === null || sourceBlob === undefined || sourceBlob.length() === 0) {
        throw new Error(`The photo BLOB with id ${id} is empty`);
    }

    if (sourceBlob.length() > 10 * 1024 * 1024) {
        throw new Error("The source photo exceeds the 10 MiB file limit");
    }

    photon.initSync({ module: photonWasm });
    const image = photon.PhotonImage.new_from_byteslice(sourceBlob.getData());
    let resized;
    let outputBlob;
    try {
        const width = image.get_width();
        const height = image.get_height();
        // Production TODO: validate dimensions before the decode above.
        // This PoC check bounds resizing work after the source is decoded.
        if (width * height > 16000000) {
            throw new Error("The source photo exceeds the 16 megapixel processing limit");
        }

        // Round down odd dimensions and keep one-pixel images at least 1 x 1.
        resized = photon.resize(
            image,
            Math.max(1, Math.floor(width / 2)),
            Math.max(1, Math.floor(height / 2)),
            photon.SamplingFilter.Lanczos3
        );

        // get_bytes() encodes PNG, preserving transparency. Store matching
        // metadata, irrespective of the source file's format or filename.
        outputBlob = OracleBlob.createTemporary(false);
        // Oracle LOB offsets start at 1.
        outputBlob.write(1, resized.get_bytes());
        const result = session.execute(
            `insert into uploaded_files 
             set filename = :filename, content_type = :content_type, file_content = :content
             returning id into :new_id`,
            {
                filename: {
                    val: `photo_${numericId}_resized.png`,
                    dir: oracledb.BIND_IN,
                    type: oracledb.STRING
                },
                content_type: {
                    val: "image/png",
                    dir: oracledb.BIND_IN,
                    type: oracledb.STRING
                },
                content: {
                    val: outputBlob,
                    dir: oracledb.BIND_IN,
                    type: oracledb.ORACLE_BLOB
                },
                new_id: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER }
            }
        );
        if (result.rowsAffected !== 1) {
            throw new Error("The resized photo was not inserted for an unknown reason");
        }
        // DML RETURNING supplies an array for each OUT bind.
        return result.outBinds.new_id[0];
    } finally {
        // Nested finally blocks attempt every cleanup even if one release fails.
        try {
            if (outputBlob) outputBlob.freeTemporary();
        } finally {
            try {
                if (resized) resized.free();
            } finally {
                image.free();
            }
        }
    }
}
/

-- the environment is required for use with ORDS, APEX, and SQL or PL/SQL
create or replace mle env photon_env imports (
    'photon' module photon,
    'photon_wasm' module photon_wasm,
    'photon_api' module photon_utilities
);

-- MLE modules and PL/SQL packages share a namespace: use a distinct API name.
create or replace package photon_api as

    procedure save_uploaded_file (
        "p_filename"     in varchar2,
        "p_content_type" in varchar2,
        "p_content"      in blob
    )
        as mle module photon_utilities
        env photon_env
        signature 'saveUploadedFile';

    function photo_details(id varchar2)
        return json as
        mle module photon_utilities
        env photon_env
        signature 'photoDetails';

    function resize_photo(id varchar2)
        return number as
        mle module photon_utilities
        env photon_env
        signature 'resizePhoto';

end;
/