-- liquibase formatted sql
-- changeset EMILY:1748009798025 stripComments:false logicalFilePath:issue_7/emily/ref_constraints/fk_todo_list_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot mle-typescript/src/database/emily/ref_constraints/fk_todo_list_users.sql:null:66f87d2a1dc31cb79d91c1806a7a2e8cbeb3a722:create

alter table todo_list
    add constraint fk_todo_list_users
        foreign key ( u_id )
            references users ( id )
        enable;

