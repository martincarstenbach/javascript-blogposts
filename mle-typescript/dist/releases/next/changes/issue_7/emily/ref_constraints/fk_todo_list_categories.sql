-- liquibase formatted sql
-- changeset EMILY:1748009798019 stripComments:false logicalFilePath:issue_7/emily/ref_constraints/fk_todo_list_categories.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot mle-typescript/src/database/emily/ref_constraints/fk_todo_list_categories.sql:null:6946c69734eac80abd1c9779bd39de8733885d17:create

alter table todo_list
    add constraint fk_todo_list_categories
        foreign key ( c_id )
            references categories ( id )
        enable;

