-- A table is required to store messages.
-- This script requires a recent SQLcl release and a connection to an Oracle Database
-- 23ai [Free] > 23.5 for aarch64 Linux or x86-64. The project's readme shows you one
-- possible way of deploying this script

drop table if exists demo_table purge;

create table demo_table (
    id number generated always as identity,
    constraint pk_demo_table primary key(id),
    ts timestamp default systimestamp not null,
    message varchar2(1000) not null
)
/

-- The remainder of this script deals with the definition of server-side JavaScript
-- Start by defining the MLE module using SQLcl's "mle create-module" command

mle create-module -filename mle-server-side-code.mjs -module-name demo_module -replace

-- Before you can use server-side JavaScript you have to create call specifications
-- Please refer to the Oracle JavaScript Developer's Guide, chapter 5 for details.

create or replace procedure process_data(
        p_message in varchar2,
        p_success out boolean,
        p_inserted_id out number
    )
    as mle module demo_module
    signature 'processData(string, Out<boolean>, Out<number>)';
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

create or replace function get_messages
    return json
    as mle module demo_module
    signature 'getMessages';
/

create or replace procedure delete_message(
        p_id number,
        p_success out boolean
    )
    as mle module demo_module
    signature 'deleteMessage(number, Out<boolean>)';
/