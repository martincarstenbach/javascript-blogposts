
-- start by defining the MLE module. Requires a recent SQLcl release
mle create-module -filename mle-server-side-code.mjs -module-name demo_module -replace

create table if not exists demo_table (
    id number generated always as identity,
    constraint pk_demo_table primary key(id),
    ts timestamp default systimestamp not null,
    message varchar2(1000) not null
)
/

create or replace procedure process_data(p_data json)
    as mle module demo_module
    signature 'processData';
/

create or replace function get_db_details
    return json
    as mle module demo_module
    signature 'getDbDetails';
/

create or replace function get_message_by_id(p_id number)
    return json
    as mle module demo_module
    signature 'getMessageById';
/