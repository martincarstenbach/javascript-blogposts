-- liquibase formatted sql
-- changeset DEMOUSER:1759832586471 stripComments:false  logicalFilePath:post-execution-debugging/demouser/mle_envs/demo_env.sql
-- sqlcl_snapshot post-execution-debugging/src/database/demouser/mle_envs/demo_env.sql:null:f52842fb868949ea47729f6fa327af585de928a2:create

create or replace mle env demouser.demo_env imports ( 'utilities' module demouser.utilities_module, 'purchaseOrder' module demouser.purchase_order_module
);

