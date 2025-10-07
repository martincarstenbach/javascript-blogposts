-- liquibase formatted sql
-- changeset DEMOUSER:1759832586608 stripComments:false  logicalFilePath:post-execution-debugging/demouser/tables/orders.sql
-- sqlcl_snapshot post-execution-debugging/src/database/demouser/tables/orders.sql:null:7730d4606cb5213048613055acd570df05f00f05:create

create table demouser.orders (
    order_id     number(12, 0) default demouser.s_orders.nextval not null enable,
    order_date   date not null enable,
    order_mode   varchar2(8 byte),
    customer_id  number(6, 0) not null enable,
    order_status number(2, 0),
    order_total  number(8, 2),
    sales_rep_id number(6, 0),
    promotion_id number(6, 0)
);

alter table demouser.orders
    add constraint pk_orders primary key ( order_id )
        using index enable;

