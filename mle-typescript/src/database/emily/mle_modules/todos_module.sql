create or replace mle module todos_module language javascript as 
/// <reference types="mle-js" />
 var priorities;
    ( function ( priorities )
        {
                priorities["LOW"]= "low";
            priorities["MEDIUM"]= "medium";
            priorities["HIGH"]= "high";
        }
    )
    ( priorities
    || ( priorities ={}) );
/**
 * Create a new user in the database and return its primary key
 *
 * @param {string} name the new user's name
 * @returns {number} the new user's primary key
 */
    export
        function newuser ( name )
            {const result = session.execute ( "insert into users (name) values (:name) returning id into :id",{name :{dir : oracledb.bind_in
            , val : name, type : oracledb.string,}, id :{type : oracledb.number, dir : oracledb.bind_out,},});
            const id = result.outbinds.id[0];
                return
                id;
            }
/**
 * Update an existing user
 *
 * Does NOT check if the user exists
 *
 * @param {string} name the new user name
 * @param id the user's ID
 */
    export
        function updateuser ( name, id )
            {
                    session.execute ( `update users
			set name = :name 
		where
			id = :id`,{name :{dir : oracledb.bind_in, val : name, type : oracledb.string,}, id :{dir : oracledb.bind_in, val : id, type : oracledb.number
                    ,},});
            }
    export
        function newcategory ( name, priority )
            {const result = session.execute ( "insert into categories (name, prio) values (:name, :prio) returning id into :id",{name :{dir : oracledb.bind_in
            , val : name, type : oracledb.string,}, prio :{dir : oracledb.bind_in, val : priority, type : oracledb.string,}, id :{type : oracledb.number
            , dir : oracledb.bind_out,},});
            const id = result.outbinds.id[0];
                return
                id;
            }
    export
        function newtodoitem ( userid, categoryid, name )
            {const result = session.execute ( "insert into todo_list(u_id, c_id, name, completed) values (:u_id, :c_id, :name, :completed) returning id into :id"
            ,{u_id :{dir : oracledb.bind_in, val : userid, type : oracledb.string,}, c_id :{dir : oracledb.bind_in, val : categoryid,
            type : oracledb.string,}, name :{dir : oracledb.bind_in, val : name, type : oracledb.string,}, id :{type : oracledb.number
            , dir : oracledb.bind_out,},});
            const id = result.outbinds.id[0];
                return
                id;
            }
/


-- sqlcl_snapshot {"hash":"ea5a6357ceae68519e100367273d427131bb00e2","type":"MLE_MODULE","name":"TODOS_MODULE","schemaName":"EMILY","sxml":""}