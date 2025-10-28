-- liquibase formatted sql
-- changeset DEMOUSER:1761590662271 stripComments:false  logicalFilePath:abstract-data-types/demouser/mle_envs/blogpost_env.sql
-- sqlcl_snapshot mle-abstract-data-types/src/database/demouser/mle_envs/blogpost_env.sql:null:524d774299070ebd6e2d6ff10a7353551a630b45:create

create or replace mle env demouser.blogpost_env imports ( 'records' module demouser.records_demo_module, 'rest' module demouser.rest_handler_module
);

