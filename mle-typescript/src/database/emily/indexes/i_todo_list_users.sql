create index i_todo_list_users on
    todo_list (
        u_id
    );


-- sqlcl_snapshot {"hash":"8bcb064bab3a7f8fd49ab7f205aa2307c1945bae","type":"INDEX","name":"I_TODO_LIST_USERS","schemaName":"EMILY","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>EMILY</SCHEMA>\n   <NAME>I_TODO_LIST_USERS</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>EMILY</SCHEMA>\n         <NAME>TODO_LIST</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>U_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      \n   </TABLE_INDEX>\n</INDEX>"}