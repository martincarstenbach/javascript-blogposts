/**
 * Example demonstrating how to process objects in MLE/JavaScript
 *
 * @param {object} data the request body as provided by node-express
 */
export function processData(message) {
	session.execute(
		`insert into demo_table(
			message
		) values (
			:message
		)`,
		[message],
	);
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
	if (Number.isNaN(id)) {
		throw new Error("please provide a numeric ID");
	}

	const result = session.execute(
		`select
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
