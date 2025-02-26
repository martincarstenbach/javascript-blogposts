/// <reference types="mle-js" />

enum priorities {
	LOW = "low",
	MEDIUM = "medium",
	HIGH = "high",
}

export function newUser(name: string): number {
	const result = session.execute(
		"insert into users (name) values (:name) returning id into :id",
		{
			name: {
				dir: oracledb.BIND_IN,
				val: name,
				type: oracledb.STRING,
			},
			id: {
				type: oracledb.NUMBER,
				dir: oracledb.BIND_OUT,
			},
		},
	);

	const id = result.outBinds.id[0];

	return id;
}

export function newCategory(name: string, priority: priorities): number {
	const result = session.execute(
		"insert into categories (name, prio) values (:name, :prio) returning id into :id",
		{
			name: {
				dir: oracledb.BIND_IN,
				val: name,
				type: oracledb.STRING,
			},
			prio: {
				dir: oracledb.BIND_IN,
				val: priority,
				type: oracledb.STRING,
			},
			id: {
				type: oracledb.NUMBER,
				dir: oracledb.BIND_OUT,
			},
		},
	);

	const id = result.outBinds.id[0];

	return id;
}

export function newToDoItem(
	userId: number,
	categoryId: number,
	name: string,
): number {
	const result = session.execute(
		"insert into todo_list(u_id, c_id, name, completed) values (:u_id, :c_id, :name, :completed) returning id into :id",
		{
			u_id: {
				dir: oracledb.BIND_IN,
				val: userId,
				type: oracledb.STRING,
			},
			c_id: {
				dir: oracledb.BIND_IN,
				val: categoryId,
				type: oracledb.STRING,
			},
			name: {
				dir: oracledb.BIND_IN,
				val: name,
				type: oracledb.STRING,
			},
			id: {
				type: oracledb.NUMBER,
				dir: oracledb.BIND_OUT,
			},
		},
	);

	const id = result.outBinds.id[0];

	return id;
}
