# Simplified GraphQL Example

This folder contains the code necessary to run GraphQL queries from within the database.

## Version

The code was tested using the following components

- Oracle Database 23ai (Free) on Linux x86-64 (version 23.4.0.24.05)
- Node v20 (LTS "Iron")
- Node packages as per `package.json`

Please refer to the [blog post](https://martincarstenbach.com/2024/06/06/creating-a-graphql-endpoint-within-the-database-redux/) for further details.

If you detect problems with the code, please file an issue.

## Using the code

After cloning this directory you need to install the NPM modules first, using `npm install`. The next step is to create the bundle.js file

```
mkdir dist
npx rollup -c
```

The resulting `dist/bundle.js` file can be loaded into the (23.4.0.24.05 or later) database as `GRAPHQL_ENDPOINT_MODULE`. Once the module is present, expose the GraphQL query to SQL and PL/SQL as follows:

```sql
create or replace function graphql_query(
  p_query varchar2,
  p_args json
) return json
as mle module GRAPHQL_ENDPOINT_MODULE
signature 'graphQLQuery';
/
```

Finally, query the endpoint, for example:

```sql
select
  json_serialize(
    graphql_query(
      'query locById($id: Int) { getLocationById(id: $id) { city country_id } }',
      JSON('{id: 1000}')
    )
    pretty
  ) graphql_result
/
 
GRAPHQL_RESULT
--------------------------------------------------------------------------------
{
  "data" :
  {
    "getLocationByID" :
    {
      "city" : "Roma",
      "country_id" : "IT"
    }
  }
}
```