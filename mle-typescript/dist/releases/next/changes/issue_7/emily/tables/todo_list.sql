-- liquibase formatted sql
-- changeset EMILY:1748009798050 stripComments:false logicalFilePath:issue_7/emily/tables/todo_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot mle-typescript/src/database/emily/tables/todo_list.sql:null:d18495b4a35cf23c48ca1ed1c0ecb97f5505d527:create

create table todo_list (
    id        number
        generated by default on null as identity minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1 cache 20
        noorder nocycle nokeep noscale
    not null enable,
    u_id      number not null enable,
    c_id      number not null enable,
    name      varchar2(255 byte) not null enable,
    completed boolean default false not null enable
);

alter table todo_list
    add constraint pk_todo_list primary key ( id )
        using index enable;

