import { assert } from "chai";

// consciously selecting the generated output over the src directory
// this way the test is more meaningful and catches issues with the
// code rollup produced.
import { graphQLQuery } from "../dist/bundle.js";

describe("All Unit Tests", () => {
	describe("Connection details", () => {
		it("The database username must not be undefined", async () => {
			const username = process.env.USER;

			assert.isDefined(username);
		});

		it("The database password must not be undefined", async () => {
			const password = process.env.PASSWORD;

			assert.isDefined(password);
		});

		it("The database connection string must not be undefined", async () => {
			const connectionstring = process.env.CONNECTION_STRING;

			assert.isDefined(connectionstring);
		});
	});

	describe("GraphQL queries", () => {
		it("Query by ID must return exactly 1 result", async () => {
			const expectedResult = {
				data: { getLocationById: { city: "Roma", country_id: "IT" } },
			};
			const result = await graphQLQuery(
				"query locById($id: Int) { getLocationById(id: $id) { city country_id } }",
				{ id: 1000 },
			);

			assert.deepEqual(result, expectedResult);
		});

		it("Number of locations must be 23", async () => {
			const result = await graphQLQuery(
				"query { getAllLocations { city country_id } }",
			);

			assert.equal(result.data.getAllLocations.length, 23);
		});

		it("Number of locations must be 23", async () => {
			const result = await graphQLQuery(
				"query { getAllLocations { city country_id } }",
			);

			assert.equal(result.data.getAllLocations.length, 23);
		});

		it("Number of US locations must be 4", async () => {
			const result = await graphQLQuery(
				"query locByCountry($country_id: String) { getLocation(country: $country_id) { city country_id state_province } }",
				{ country_id: "US" },
			);

			assert.equal(result.data.getLocation.length, 4);
		});
	});
});
