import { graphql } from "graphql";
import { generateSchema } from "./graphQLschema.js";

/**
 * Perform a generic GraphQL query
 * @param {String} queryText - the graphQL query
 * @param {object} args - arguments to the query, empty array if none
 * @returns {object} the JSON representation of the query result. Might contain errors, too
 */
export async function graphQLQuery(queryText, args) {
	const schema = await generateSchema();
	const results = await graphql({
		schema,
		source: queryText,
		variableValues: args,
	});

	return results;
}
