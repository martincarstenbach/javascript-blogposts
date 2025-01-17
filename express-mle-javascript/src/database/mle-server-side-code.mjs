/**
 * Example demonstrating how to process objects in MLE/JavaScript. A
 * message is passed via express. An OUT variable (success) is populated
 * based on the success of the operation. It should always return true,
 * except for cases where the insert fails (no further storage etc). Those
 * conditions however are reported back via exceptions, caught in the express
 * app
 *
 * @param {object} data the request body as provided by node-express
 * @param {boolean} success an OUT variable indicating success or failure
 */
export function processData(message, success) {
	const result = session.execute(
		`insert into demo_table(
			message
		) values (
			:message
		)`,
		[message],
	);

	// success is defined as an OUT variable in the call spec (deploy.sql)
	// to change the value of an OUT variable, the Out<> interface is required
	// and you use the object.value property to update the bind variable. See
	// Oracle JavaScript Developer's Guide, chapter 5 for details.

	// biome-ignore lint/complexity/noUselessTernary: type cast needed for MLE
	success.value = result.rowsAffected === 1 ? true : false;
}

/**
 * Get the username and database version
 *
 * @returns username and database version
 */
export function getDbDetails() {
	const data = {
		username: "unknown",
		release: "unknown",
	};

	try {
		let result = session.execute("select user");
		data.username = result.rows[0].USER;

		result = session.execute(
			"select version_full from PRODUCT_COMPONENT_VERSION",
		);
		data.release = result.rows[0].VERSION_FULL;
	} catch (err) {
		throw new Error(`an unexpected error occurred: ${err}`);
	}

	return data;
}

/**
 * Fetch all messages
 *
 * @returns a array of messages, or an empty array in case there are none
 */
export function getMessages() {
	const result = session.execute(
		`select
			id,
            message,
            ts
        from
            demo_table`,
	);

	if (result.rows.length === 0) {
		return [];
	}

	return result.rows;
}

/**
 * Fetch a specific message by its ID
 *
 * @param {number} id the message to fetch
 * @returns the message as the single element in an array, or an empty array if there is none
 */
export function getMessageById(id) {
	// biome-ignore lint/suspicious/noGlobalIsNan: coercion to number is acceptable
	if (isNaN(id)) {
		throw new Error("please provide a numeric ID");
	}

	const result = session.execute(
		`select
			id,
            message,
            ts
        from
            demo_table
        where
            id = :id`,
		[id],
	);

	if (result.rows.length === 0) {
		return [];
	}

	return result.rows;
}

/**
 * Delete a message from demo_table. Success will be true if a messages was
 * deleted, in case of a _no data found_ situation an appropriate status
 * message is returned
 *
 * @param {number} id the ID of the message to be deleted
 * @param {boolean} success an OUT variable indicating success or failure
 */
export function deleteMessage(id, success) {
	// biome-ignore lint/suspicious/noGlobalIsNan: coercion to number is acceptable
	if (isNaN(id)) {
		throw new Error("please provide a numeric ID");
	}

	const result = session.execute(
		`delete
			demo_table
		where
			id = :id`,
		[id],
	);

	// biome-ignore lint/complexity/noUselessTernary: type cast needed for MLE
	success.value = result.rowsAffected === 1 ? true : false;
}
