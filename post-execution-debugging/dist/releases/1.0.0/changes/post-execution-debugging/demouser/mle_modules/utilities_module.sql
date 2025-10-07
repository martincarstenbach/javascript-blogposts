-- liquibase formatted sql
-- changeset DEMOUSER:1759832586539 stripComments:false  logicalFilePath:post-execution-debugging/demouser/mle_modules/utilities_module.sql
-- sqlcl_snapshot post-execution-debugging/src/database/demouser/mle_modules/utilities_module.sql:null:d8fcebaa45c1ba966c331480b5a304ff531130ae:create

create or replace mle module demouser.utilities_module language javascript as 
/**
 * Parses a string of key-value pairs separated by semicolons into an object.
 * Each pair should be in the format "key=value".
 *
 * @param {string} inputString - The input string containing key-value pairs.
 * @returns {Object} The resulting object with keys and values.
 * @throws {TypeError} If the input is not a non-null string.
 */
    export function parseKeyValueString(inputString) {
	if (typeof inputString !== "string" || inputString === null) {
		throw new TypeError("Input must be a non-null string");
	}

	const myObject = {};
	if (inputString.length === 0) {
		return myObject;
	}

	const kvPairs = inputString.split(";");
	kvPairs.forEach((pair) => {
		const tuple = pair.split("=");
		if (tuple.length === 1) {
			tuple[1] = false;
		} else if (tuple.length !== 2) {
			throw (
				"parse error: you need to use exactly one " +
				" '=' between key and value and not use '=' in either " +
				"key or value"
			);
		}
		myObject[tuple[0]] = tuple[1];
	});

	return myObject;
}
/

