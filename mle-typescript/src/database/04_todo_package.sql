--liquibase formatted sql
--changeset martincarstenbach:4 failOnError:true labels:tables endDelimiter:/ stripComments:false

create or replace package todo_package as

    function new_user(
        p_name varchar2
    ) return number
    as mle module todos_module signature 'newUser';

    function new_category(
        p_name varchar2,
        p_prio varchar2
    ) return number
    as mle module todos_module signature 'newCategory';

    function new_todo_item(
        p_user_id number,
        p_category_id number,
        p_name varchar2
    ) return number
    as mle module todos_module signature 'newToDoItem';

end todo_package;
/