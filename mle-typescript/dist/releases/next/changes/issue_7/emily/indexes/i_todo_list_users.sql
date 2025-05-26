-- liquibase formatted sql
-- changeset EMILY:1748009797981 stripComments:false logicalFilePath:issue_7/emily/indexes/i_todo_list_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot mle-typescript/src/database/emily/indexes/i_todo_list_users.sql:null:8bcb064bab3a7f8fd49ab7f205aa2307c1945bae:create

create index i_todo_list_users on
    todo_list (
        u_id
    );

