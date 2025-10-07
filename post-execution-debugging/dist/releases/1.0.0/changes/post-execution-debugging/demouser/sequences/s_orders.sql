-- liquibase formatted sql
-- changeset DEMOUSER:1759832586593 stripComments:false  logicalFilePath:post-execution-debugging/demouser/sequences/s_orders.sql
-- sqlcl_snapshot post-execution-debugging/src/database/demouser/sequences/s_orders.sql:null:afc788cc62448f6b7851e96254cd8d8ede87d1e9:create

create sequence demouser.s_orders minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 /* start with n */ cache 100 noorder
nocycle nokeep noscale global;

