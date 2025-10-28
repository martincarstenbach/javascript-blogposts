-- liquibase formatted sql
-- changeset DEMOUSER:1761590662366 stripComments:false  logicalFilePath:abstract-data-types/demouser/procedures/process_product_data.sql
-- sqlcl_snapshot mle-abstract-data-types/src/database/demouser/procedures/process_product_data.sql:null:d4877ce7b46df91c3a22e9c3c2bc08052de9ba2a:create

create or replace procedure demouser.process_product_data (
    p_data soe.orderentry.prod_rec
) as mle module records_demo_module signature 'processProductData';
/

