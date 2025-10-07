
  CREATE OR REPLACE MLE MODULE "UTILITIES_MODULE" 
   LANGUAGE JAVASCRIPT AS 
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


-- sqlcl_snapshot {"hash":"1233657f5e474143e003d9b421a97020a578a632","type":"MLE_MODULE","name":"UTILITIES_MODULE","schemaName":"DEMOUSER","sxml":""}