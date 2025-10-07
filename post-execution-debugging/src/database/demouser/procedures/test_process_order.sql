create or replace procedure test_process_order as
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


-- sqlcl_snapshot {"hash":"d508aa43c7b9b0266e78d42f07d2dfeb422d574d","type":"PROCEDURE","name":"TEST_PROCESS_ORDER","schemaName":"DEMOUSER","sxml":""}