create index i_todo_list_categories on
    todo_list (
        c_id
    );


-- sqlcl_snapshot {"hash":"7a4e761c17ee5dacf151592baf4fcaec54d918a2","type":"INDEX","name":"I_TODO_LIST_CATEGORIES","schemaName":"EMILY","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>EMILY</SCHEMA>\n   <NAME>I_TODO_LIST_CATEGORIES</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>EMILY</SCHEMA>\n         <NAME>TODO_LIST</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>C_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      \n   </TABLE_INDEX>\n</INDEX>"}