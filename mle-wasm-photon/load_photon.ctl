LOAD DATA
INFILE *
APPEND
INTO TABLE wasm_modules
FIELDS TERMINATED BY ','
TRAILING NULLCOLS
(
    module_name    CHAR(255),
    lob_filename   FILLER CHAR(1024),
    module_version CONSTANT '0.3.3',
    module_comment CHAR(255),
    module_blob    LOBFILE(lob_filename) TERMINATED BY EOF
)
BEGINDATA
photon_rs.js,stage/photon_rs.js,Photon JavaScript bindings
photon_rs_bg.wasm,stage/photon_rs_bg.wasm,Photon WebAssembly binary