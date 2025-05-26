-- liquibase formatted sql
-- changeset EMILY:1748009797977 stripComments:false logicalFilePath:issue_7/emily/indexes/i_todo_list_categories.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot mle-typescript/src/database/emily/indexes/i_todo_list_categories.sql:null:7a4e761c17ee5dacf151592baf4fcaec54d918a2:create

create index i_todo_list_categories on
    todo_list (
        c_id
    );

