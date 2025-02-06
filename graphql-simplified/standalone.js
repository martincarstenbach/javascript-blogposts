/**
 * This file allows you to test the GraphQL query without a database deployment.
 *
 * Assuming you created the demo database as described in the readme, you can
 * invoke this test as follows:
 *
 * USER=demouser PASSWORD=${PASSWORD} CONNECTION_STRING="localhost/freepdb1" node standalone.js
 *
 * The bundle.js file must have been created first, and the database initialisation must also
 * have completed or else you will run into errors.
 */

import { graphQLQuery } from "./dist/bundle.js";

const input = {
	id: 1000,
};

const result = await graphQLQuery(
	"query locById($id: Int) { getLocationById(id: $id) { city country_id } }",
	input,
);

if ("errors" in result) {
	console.log(result.errors);
} else {
	console.log(
		`The location stored in the database for ID ${input.id} is: ${result.data.getLocationById.city} located in ${result.data.getLocationById.country_id}`,
	);
}
