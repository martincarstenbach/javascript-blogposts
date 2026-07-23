import { describe, it, expect } from "vitest";

// consciously selecting the generated output over the src directory
// this way the test is more meaningful and catches issues with the
// code rollup produced.
import { graphQLQuery } from "../dist/bundle.js";

describe("All Unit Tests", () => {
	describe("Connection details", () => {
		it("The database username must not be undefined", () => {
			const username = process.env.DB_USERNAME;
			expect(username).toBeDefined();
		});

		it("The database password must not be undefined", () => {
			const password = process.env.DB_PASSWORD;
			expect(password).toBeDefined();
		});

		it("The database connection string must not be undefined", () => {
			const connectionString = process.env.DB_CONNECTION_STRING;
			expect(connectionString).toBeDefined();
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

			expect(result).toEqual(expectedResult);
		});

		it("Number of locations must be 23", async () => {
			const result = await graphQLQuery(
				"query { getAllLocations { city country_id } }",
			);

			expect(result.data.getAllLocations.length).toBe(23);
		});

		it("Number of US locations must be 4", async () => {
			const result = await graphQLQuery(
				"query locByCountry($country_id: String) { getLocation(country: $country_id) { city country_id state_province } }",
				{ country_id: "US" },
			);

			expect(result.data.getLocation.length).toBe(4);
		});
	});
});
