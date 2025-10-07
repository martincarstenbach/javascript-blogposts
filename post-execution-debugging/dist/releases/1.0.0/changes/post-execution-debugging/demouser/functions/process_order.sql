-- liquibase formatted sql
-- changeset DEMOUSER:1759832586442 stripComments:false  logicalFilePath:post-execution-debugging/demouser/functions/process_order.sql
-- sqlcl_snapshot post-execution-debugging/src/database/demouser/functions/process_order.sql:null:244c0226275ab1a4fedb88e0f54981b9c505364a:create

create or replace function demouser.process_order (
    p_data varchar2
) return boolean as mle module purchase_order_module env demo_env signature 'processOrder';
/

