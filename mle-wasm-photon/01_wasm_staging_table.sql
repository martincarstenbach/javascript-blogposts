-- this  table will hold the photon JS bindings and the compiled wasm module 
-- you can use SQL Loader or any other tool to load the module_blob.
-- see 02_stage_photon for more details about staging the third party code
create table wasm_modules (
    module_name         varchar2(255) not null,
    module_version      varchar2(255),
    module_blob         blob,
    module_comment      varchar2(255),
    constraint pk_wasm_modules primary key (module_name, module_version)
);