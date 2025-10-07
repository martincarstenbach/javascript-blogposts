create or replace function process_order (
    p_data varchar2
) return boolean as mle module purchase_order_module env demo_env signature 'processOrder';
/


-- sqlcl_snapshot {"hash":"f19bde1390988832fc41ae74c735c28fdcbc5ac3","type":"FUNCTION","name":"PROCESS_ORDER","schemaName":"DEMOUSER","sxml":""}