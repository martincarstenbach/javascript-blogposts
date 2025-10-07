declare
    ctx dbms_mle.context_handle_t;
    snippet clob;
begin
    ctx := dbms_mle.create_context(
        environment => 'DEMO_ENV'
    );

    snippet := q'~
        (async () => {
            const { processOrder } = await import('purchaseOrder');
            const orderData = 'order_date=2023-04-24t10:27:52;order_mode=themode;customer_id=1;order_status=2;order_total=42;sales_rep_id=1;promotion_id=1';
            const result = processOrder(orderData);
        })();
    ~';

    dbms_mle.eval(ctx, 'JAVASCRIPT', snippet);

    dbms_mle.drop_context(ctx);  
exception
    when others then
        dbms_mle.drop_context(ctx);
        raise;
end;
/
