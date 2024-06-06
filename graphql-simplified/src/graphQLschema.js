import { makeExecutableSchema } from '@graphql-tools/schema';
import { getLocationById, getLocation, getAllLocations } from './databaseAPI.js';

const typeDefs = `
"""
this type represents HR.LOCATIONS.
"""
type Location {
    location_id:     Int
    street_address:  String
    postal_code:     String
    city:            String
    state_province:  String
    country_id:      String
}

"""
Each GraphQL schema must at least provide a way to query it. Other
options include changing (mutation) and subscibing to data. This
query type defines the 3 API calls and what data is returned.
"""
type Query {
    getAllLocations: [Location]
    getLocationById(id: Int): Location
    getLocation(street: String, postalCode: String, city: String, stateProvince: String, country:String ): [Location]
}
`;

const resolvers = {
	Query: {
		getAllLocations: async () => {
			return await getAllLocations();
		},
		getLocationById: async (_, { id }) => {
			return await getLocationById(id);
		},
		getLocation: async (_, { street, postalCode, city, stateProvince, country }) => {
			return await getLocation(street, postalCode, city, stateProvince, country);
		}
	}
};

export function generateSchema() {
	const executableSchema = makeExecutableSchema({
		typeDefs,
		resolvers
	});

	return executableSchema;
}
