# express-mle-javascript

Example how to use node-[express](https://expressjs.com/) with MLE/JavaScript.

**NOTE** you are probably better off using Oracle REST Data Services ([ORDS](https://www.oracle.com/ords)) instead of express. ORDS provides a lot more than express out of the box including, but not limited to, authorisation and authentication.

## Database Setup and Configuration

You require an Oracle Database (Free) instance. The easiest way to create one is to use a container image. This example features [Gerald Venzl's image](https://hub.docker.com/r/gvenzl/oracle-free) Make sure not to use the `-slim` image flavours, these don't come with Multilingual Engine/MLE.

Here's an example compose file you can use as the starting point.

>The instructions in the readme refer to rootless `podman`/`podman-compose`, adapt as necessary for other container runtimes like Docker. You may also want to bump the version as newer releases become available.

```yaml
# THIS IS NOT A PRODUCTION SETUP - LAB USE ONLY!
services:
    oracle:
        image: docker.io/gvenzl/oracle-free:23.6
        ports:
            - 1521:1521
        environment:
            - ORACLE_PASSWORD_FILE=/run/secrets/oracle-passwd
        volumes:
            - oradata-vol:/opt/oracle/oradata
        networks:
            - backend
        healthcheck:
            test: [ "CMD", "healthcheck.sh" ]
            interval: 10s
            timeout: 5s
            retries: 10
            start_period: 5s
        secrets:
            - oracle-passwd

volumes:
    oradata-vol:

networks:
    backend:

secrets:
    oracle-passwd:
        external: true
```

The file worked brilliantly with `podman-compose 1.0.6-1` and `podman 4.9.3`. Make sure you defined a podman secret named `oracle-passwd` before bringing the database up.

### Application User

Once the database is up and running (visible in the output of `podman logs <container>`) you need to set up an application user as follows in `FREEPDB1`.

The easiest way to do that is via [SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/). Either install it locally or use the [official image](https://container-registry.oracle.com/ords/ocr/ba/database/sqlcl). The latter is preferable if you don't want to deal with SQLcl's dependencies such as the Java Runtime.

1. **Get required connection information**

    Before starting you need to know

    - the name of the database container to connect to
    - the network it used

    Use the following snippet to get the container name
    ```sh
    $ podman ps --format "{{.Image}} --> use {{.Names}}"
    docker.io/gvenzl/oracle-free:23.6 --> use dbfree_oracle_1
    ```

    Similarly, use `podman network ls` to get the network. Let's assume the network name is `dbfree_backend`.

1. **Start SQLcl**

    Don't forget to update the network name!

    ```sh
    cd express-mle-javascript/src/

    podman run -it --rm \
    --volume ./database/:/opt/oracle/sql_scripts:Z \
    --network ${compose_network:-"dbfree_backend"} \
    container-registry.oracle.com/database/sqlcl:latest /nolog
    ```

    This will launch SQLcl.

1. **Connect to the SYSTEM account using the container name you worked out earlier**

    If you created the database using the compose file shown above, the following command will work without a change.

    ```sql
    connect system@dbfree_oracle_1/freepdb1
    ```

1. **Switch to the default Pluggable Database and create the user**

    Using the container image for Oracle Database Free you get a default Pluggable Database ready for use. It's name is `FREEPDB1`. Please update the password :)

    ```sql
    alter session set container = FREEPDB1;

    create user app_user identified by "someSecretPasswordOfYourLiking"
    default tablespace users
    quota 1g on users;

    -- these are required for MLE/JavaScript
    grant execute on javascript to app_user;
    grant execute dynamic MLE to app_user;
    grant db_developer_role to app_user;
    grant soda_app to app_user;

    alter user app_user default role all;
    ```

This concludes the database setup.

### Code deployment

Connect as the newly created user and run the `deploy.sql` script:

```
connect app_user@dbfree_oracle_1/freepdb1
start deploy.sql
```

You should see the deployment on your screen:

```
SQL> start deploy
MLE Module demo_module created

Table DEMO_TABLE created.


Procedure PROCESS_DATA compiled


Function GET_DB_DETAILS compiled


Function GET_MESSAGE_BY_ID compiled
```

## Start the application

Open a new terminal and start the express application as follows:

```sh
cd ./express-mle-javascript
npm i
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

To test if these operations are available, you can run the unit test suite:

```
npm run test

> test
> npx mocha ./test

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