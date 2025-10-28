-- liquibase formatted sql
-- changeset DEMOUSER:1761590662241 stripComments:false  logicalFilePath:abstract-data-types/demouser/functions/get_product_details.sql
-- sqlcl_snapshot mle-abstract-data-types/src/database/demouser/functions/get_product_details.sql:null:c2cc289d8e0d0e84ff21d8cccbb3e43906e325ce:create

create or replace function demouser.get_product_details (
    p_product_id   in soe.products.product_id%type,
    p_warehouse_id in number
) return soe.orderentry.prod_rec as
    l_product_data soe.orderentry.prod_rec;
begin
    select
        p.product_id,
        p.product_name,
        p.product_description,
        p.category_id,
        p.weight_class,
        p.warranty_period,
        p.supplier_id,
        p.product_status,
        p.list_price,
        p.min_price,
        p.catalog_url,
        i.quantity_on_hand
    into l_product_data
    from
        soe.products    p,
        soe.inventories i
    where
            p.product_id = p_product_id
        and i.product_id = p.product_id
        and i.warehouse_id = p_warehouse_id;

    return l_product_data;
end;
/

