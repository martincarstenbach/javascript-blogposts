alter table todo_list
    add constraint fk_todo_list_categories
        foreign key ( c_id )
            references categories ( id )
        enable;


-- sqlcl_snapshot {"hash":"6946c69734eac80abd1c9779bd39de8733885d17","type":"REF_CONSTRAINT","name":"FK_TODO_LIST_CATEGORIES","schemaName":"EMILY","sxml":""}