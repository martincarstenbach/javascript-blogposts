# Simplified GraphQL Example

This folder contains the code necessary to run GraphQL queries from within an [Oracle Database Free](https://www.oracle.com/database/free/) instance. It extends an earlier example, this time however it uses the _GraphQL Reference implementation_ to perform GraphQL queries. Please refer to the [blog post](https://martincarstenbach.com/2024/06/06/creating-a-graphql-endpoint-within-the-database-redux/) for further details.

> [!IMPORTANT]
> Quite a few things changed in the meantime: GraphQL support has been added to Oracle AI Database 26ai, you don't need to use this code. More details [can be found in the documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/gphql/oracle-ai-database-support-graphql.html)

## Versions Used

The code was tested using the following components:

- Oracle Database 23ai (Free) on Linux x86-64 (version 23.26.2)
- Node v24 (LTS "krypton")
- Node packages as per `package.json`

If you detect problems with the code, kindly file an issue. You may also have to update the software releases, this code acts as an example and isn't maintained on a regular basis.

## Using GraphQL in Oracle Database Free

You need a database to deploy the code against. The easiest way is to use the [docker](../database/compose-docker-db.yml) or [podman](../database/compose-podman-db.yml) compose file. You also need to deploy the 2 scripts in the `../database/initialisation` folder to your demo account. This is done automagically by the aforementioned compose files.

Start by installing the NPM modules first, using `npm install`. The next step is to create the `bundle.js` file. This is a job for [Rollup](https://rollupjs.org/). Create the `bundle.js` like so:

```sh
npx rollup -c
```

The resulting `dist/bundle.js` file can be loaded into the Oracle Database Free instance as `GRAPHQL_ENDPOINT_MODULE`. Use a recent [SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/) version to do so. Provided you used the [compose file shippping with this repo](../database/compose.yml) you can connect to the database using the `demouser` account and load the module:

```
sql demouser@localhost/freepdb1

[enter password when prompted]

SQL> mle create-module -filename dist/bundle.js -module-name GRAPHQL_ENDPOINT_MODULE -version 260723
```

Once the module is present, expose the GraphQL query to SQL and PL/SQL as follows:

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

select
  json_serialize(
    graphql_query(
      'query { getAllLocations { city country_id } }',
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
    "getAllLocations" :
    [
      {
        "city" : "Roma",
        "country_id" : "IT"
      },
[ ... output removed for clarity ... ]
      {
        "city" : "Mexico City",
        "country_id" : "MX"
      }
    ]
  }
}

select
  json_serialize(
    graphql_query(
      'query locByCity($city: String) { getLocation(city: $city) { city country_id state_province } }',
      JSON('{city: "Utrecht"}')
    )
    pretty
  ) graphql_result
/

GRAPHQL_RESULT
--------------------------------------------------------------------------------
{
  "data" :
  {
    "getLocation" :
    [
      {
        "city" : "Utrecht",
        "country_id" : "NL",
        "state_province" : "Utrecht"
      }
    ]
  }
}    
```

That's it! Happy Querying.