-- liquibase formatted sql
-- changeset DEMOUSER:1759832586567 stripComments:false  logicalFilePath:post-execution-debugging/demouser/procedures/test_process_order.sql
-- sqlcl_snapshot post-execution-debugging/src/database/demouser/procedures/test_process_order.sql:null:2334cf2ba641bbdb5eaaa9f593c81c24cda95cb3:create

create or replace procedure demouser.test_process_order as
    l_success boolean := false;
    l_str     varchar2(256);
begin
    l_str := 'order_date=2023-04-24T10:27:52;order_mode=theMode;customer_id=1;order_status=2;order_total=42;sales_rep_id=1;promotion_id=1'
    ;
    l_success := process_order(l_str);

    -- you should probably think of a better success/failure evaluation
    if l_success then
        dbms_output.put_line('success');
    else
        dbms_output.put_line('false');
    end if;

end;
/

