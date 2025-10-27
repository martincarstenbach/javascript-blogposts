create or replace procedure demouser.process_product_data (
    p_data soe.orderentry.prod_rec
) as mle module records_demo_module signature 'processProductData';
/


-- sqlcl_snapshot {"hash":"d4877ce7b46df91c3a22e9c3c2bc08052de9ba2a","type":"PROCEDURE","name":"PROCESS_PRODUCT_DATA","schemaName":"DEMOUSER","sxml":""}