/**
 * Helper function to connect to the database. Tests for the availability of the
 * process object (which is not present in MLE) and either returns a node-oracledb
 * or a mle-js-oracledb connection to the caller
 * @returns [IConnection || Connection] a connection to the database
 */
async function getConn() {
	if (typeof process === 'undefined') {
		// this is most likely the MLE branch
		const { default: oracledb } = await import('mle-js-oracledb');
		return oracledb.defaultConnection();
	} else {
		// this is most likely node-oracledb
		if (
			process.env.USER === undefined ||
			process.env.PASSWORD === undefined ||
			process.env.CONNECTION_STRING === undefined
		) {
			throw new Error('provide username, password and connection string as environment variables');
		}

		const { default: oracledb } = await import('oracledb');
        global.oracledb = oracledb;

		const connection = await oracledb.getConnection({
			user: process.env.USER,
			password: process.env.PASSWORD,
			connectString: process.env.CONNECTION_STRING
		});

		return connection;
	}
}

/**
 * Helper function to convert all keys of a query result to lower case
 * @param {Array} rows - the result of a SQL query
 * @returns [Array] the same array of objects, however with the keys converted to lc
 */
function resultToLCKeys(rows) {
	if (Array.isArray(rows)) {
		// this is a new array, emnpty at first, but it will contain all the "rows"
		// from the result set with their keys converted to lower case
		let newDataArray = [];
		// now convert all keys of the object to lower case and append the new
		// object to the array that is returned by the function
		for (let obj of rows) {
			// some extra sanity checking
			if (typeof obj !== 'object') {
				throw new Error(
					'something is wrong with this row in the result set, did you specify OUT_FORMAT_OBJECT?'
				);
			}
			newDataArray.push(
				Object.fromEntries(Object.entries(obj).map(([k, v]) => [k.toLowerCase(), v]))
			);
		}

		return newDataArray;
	} else if (typeof rows === 'object') {
		const dataLC = Object.fromEntries(Object.entries(rows).map(([k, v]) => [k.toLowerCase(), v]));

		return dataLC;
	} else {
		throw new Error('unknown input');
	}
}

/**
 * Fetch a location from the database by ID (= primary key)
 * This function is required by the resolver in the GraphQL Query type
 * @returns {Location} the location
 */
export async function getLocationById(id) {
	const connection = await getConn();

	const result = await connection.execute(
		`select
                location_id,
                street_address,
                postal_code,
                city,
                state_province,
                country_id
            from
                locations
            where
                location_id = :id`,
		[id],
		{
			outFormat: oracledb.OUT_FORMAT_OBJECT
		}
	);

	const data = result.rows[0];
	return resultToLCKeys(data);
}

/**
 * Fetch all locations by parameter from the database
 * This function is required by the resolver in the GraphQL Query type
 * @returns {[Location]} an array of location types
 */

export async function getLocation(street, postalCode, city, stateProvince, country) {
	const connection = await getConn();

	// construct the where clause and bind variables
	let bindValues = [];
	let sql = `select
        location_id,
        street_address,
        postal_code,
        city,
        state_province,
        country_id
    from
        locations
    where
        1 = 1 `;

	if (typeof street !== 'undefined') {
		sql += 'and street_address = :street ';
		bindValues.push(street);
	}

	if (typeof postalCode !== 'undefined') {
		sql += 'and postal_code = :postalCode ';
		bindValues.push(postalCode);
	}

	if (typeof city !== 'undefined') {
		sql += 'and city = :city ';
		bindValues.push(city);
	}

	if (typeof stateProvince !== 'undefined') {
		sql += 'and state_provice = :stateProvince ';
		bindValues.push(stateProvince);
	}

	if (typeof country !== 'undefined') {
		sql += 'and country_id = :country ';
		bindValues.push(country);
	}

	const result = await connection.execute(
        sql,
        bindValues,
        {
			outFormat: oracledb.OUT_FORMAT_OBJECT
		}
    );

	const data = result.rows;
	return resultToLCKeys(data);
}

/**
 * Fetch all locations from the database
 * This function is required by the resolver in the GraphQL Query type
 * @returns {[Location]} an array of location types
 */
export async function getAllLocations() {
	const connection = await getConn();

	const result = await connection.execute(
		`select
            location_id,
            street_address,
            postal_code,
            city,
            state_province,
            country_id
        from
            locations`,
		[],
		{
			outFormat: oracledb.OUT_FORMAT_OBJECT
		}
	);

	const data = result.rows;
	return resultToLCKeys(data);
}
