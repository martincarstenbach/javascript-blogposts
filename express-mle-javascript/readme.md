# Express, MLE, and JavaScript

A quick&dirty example how to use node-[express](https://expressjs.com/) with Oracle's MLE/JavaScript.

> [!TIP]
> you are probably better off using Oracle REST Data Services ([ORDS](https://www.oracle.com/ords)) instead of express. ORDS provides a lot more than express out of the box including, but not limited to, authorisation and authentication.

## Database Setup and Configuration

You require an Oracle Database (Free) instance; the easiest way to create one is to use a container image. Feel free to use the [podman](../database/compose-podman-db.yml) or [docker](../database/compose-docker-db.yml) compose file, which is [super easy to use](../database/README.md).

### Application User

Once the database is up and running, you need to set up an application user as follows in `FREEPDB1`. That is, unless you used the compose file as suggested earlier, in which case you don't need to complete this step because an application user is created for you as soon as the container starts. Please skip that entire section.

1. **Start SQLcl**

    [SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/) is required for the deployment of the seed data and code, so let's use it for the user creation as well. Ignore this section if you used Gerald Venzl's container image and the aforementioned compose file. If you didn't, adjust as necessary for your environment.

    ```
    sql system@localhost/freepdb1

    SQLcl: Release 26.2 Production on Thu Jul 23 15:15:57 2026

    Copyright (c) 1982, 2026, Oracle.  All rights reserved.

    Password? (**********?) ***************
    Last Successful login time: Thu Jul 23 2026 15:16:04 +02:00

    Connected to:
    Oracle AI Database 26ai Free Release 23.26.2.0.0 - Develop, Learn, and Run for Free
    Version 23.26.2.0.0

    SQL> 
    ```

    You are connected as SYSTEM, so please remember: with great power comes great responsibility.

1. **Create the application user**

    Using the container image for Oracle Database Free you get a default Pluggable Database ready for use. It's name is `FREEPDB1`

    ```sql
    show con_name
    -- must be "FREEPDB1"

    create user demouser identified by "someSecretPasswordOfYourLiking"
    default tablespace users
    quota 1g on users;

    -- these are required for MLE/JavaScript
    grant execute dynamic MLE to demouser;
    grant db_developer_role to demouser;
    grant soda_app to demouser;

    alter user demouser default role all;
    ```

This concludes the user setup.

### Code deployment

Connect as the newly created user and run the `deploy.sql` script.

```sql
connect demouser@localhost/freepdb1
cd express-mle-javascript/src/database
start deploy.sql
```

This deploys the necessary table, and MLE/JavaScript code required for the express application.

## Start the application

1. **Provide required environment variables**

    Access to the database is governed by 3 environment parameters:

    - DB_USERNAME
    - DB_PASSWORD
    - DB_CONN_STRING

    Export these in your session.

1. **Start the application**

    Use the same terminal to start the express application as follows:

    ```sh
    cd ./express-mle-javascript
    npm install
    npm run dev
    ```

## Have fun!

Test the application by querying session info:

```sh
curl --silent http://localhost:3000/api/info | jq
```

You can post a message to the database:

```sh
curl --silent --json '{ "message": "this message has been provided via curl" }' \
http://localhost:3000/api/messages/
```

Retrieve messages from the database:

```sh
curl --silent http://localhost:3000/api/messages | jq
```

You can also get specific messages by their ID. Here's how to retrieve the last message inserted:

```sh
lastMessage=$(curl --silent http://localhost:3000/api/messages | jq 'map(.ID) | max')

curl --silent http://localhost:3000/api/messages/${lastMessage:-1} | jq
```

And finally, you can delete messages, too

```sh
lastMessage=$(curl --silent http://localhost:3000/api/messages | jq 'map(.ID) | max')

curl --request DELETE --silent http://localhost:3000/api/messages/${lastMessage:-1}
```

To test if these operations are available, you can run the unit test suite. Remember that environment variables for username, password, and connection string are required.

```sh
npm run test

> test
> npm run test

  All Unit Tests
    Session Info tests
      ✔ should print session info (105ms)
    Posting a message
      ✔ should post a message to the database successfully (39ms)
      ✔ should fail posting a message to the database
    Retrieval of all messages
      ✔ should retrieve one or more messages from the database
    Retrieval of a single message
      ✔ should retrieve the last message posted from the database
      ✔ should fail to retrieve a message due to an invalid parameter type
      ✔ should fail to retrieve a message due to a negative ID
    Deleting messages
      ✔ should delete the last message inserted
      ✔ should fail to delete a message due to an invalid parameter type
      ✔ should fail to delete a message due to a negative ID


  10 passing (304ms)
```

Happy testing!