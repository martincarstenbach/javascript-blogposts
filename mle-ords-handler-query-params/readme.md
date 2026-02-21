# Handling Query Parameters in JavaScript-based ORDS Endpoints

This folder contains the complete example demonstrating how to work with query parameters in JavaScript-based ORDS handlers safely. For example:

```
$ curl -s 'http://localhost:8080/ords/demouser/v1/actionItem/?limit=1' | jq .
{
  "items": [
    {
      "total_count": 3,
      "actionitem": {
        "actionId": 2,
        "actionName": "conduct q1 customer feedback interviews",
        "status": "OPEN",
        "team": [
          {
            "assignmentId": 6,
            "role": "MEMBER",
            "staffId": 5,
            "staffName": "elliott brooks"
          },
          {
            "assignmentId": 5,
            "role": "LEAD",
            "staffId": 1,
            "staffName": "avery johnson"
          }
        ]
      }
    }
  ],
  "hasMore": true,
  "totalRows": 3
}
```

Please refer to the [blog post](https://martincarstenbach.com/2026/02/20/handling-query-parameters-in-javascript-based-ords-endpoints/) for all the details.

## Requirements

Oracle REST Data Services ([ORDS](https://www.oracle.com/ords)) enables REST APIs for your Oracle Database. You therefore need both an ORDS instance as well as a database, to which ORDS connects. The quickest way to get these is to use one of the compose files in the database directory (more details can be found in the [readme](../database/README.md))

The database schema to which you deploy will be REST-enabled by the code.

You also need a current [SQLcl](https://www.oracle.com/sqlcl) version. 

This application was tested with

- Oracle AI Database 26ai Free 23.26.1
- ORDS 25.4.0
- SQLcl 25.4.0

Newer versions _shoul_ work, too, please raise an issue if not.

## Deployment

Connect to the user you want to deploy to using SQLcl, then run `00_deploy.sql`. The script sets the Liquibase engine to Oracle's SQLcl, and starts the deployment. If you used the provided compose file, the demouser can be used as the deployment target. It has all the necessary privileges.
