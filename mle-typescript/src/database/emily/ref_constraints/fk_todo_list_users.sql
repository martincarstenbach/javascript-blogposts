alter table todo_list
    add constraint fk_todo_list_users
        foreign key ( u_id )
            references users ( id )
        enable;


-- sqlcl_snapshot {"hash":"66f87d2a1dc31cb79d91c1806a7a2e8cbeb3a722","type":"REF_CONSTRAINT","name":"FK_TODO_LIST_USERS","schemaName":"EMILY","sxml":""}