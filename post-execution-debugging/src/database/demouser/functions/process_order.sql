create or replace function demouser.process_order (
    p_data varchar2
) return boolean as mle module purchase_order_module env demo_env signature 'processOrder';
/


-- sqlcl_snapshot {"hash":"244c0226275ab1a4fedb88e0f54981b9c505364a","type":"FUNCTION","name":"PROCESS_ORDER","schemaName":"DEMOUSER","sxml":""}