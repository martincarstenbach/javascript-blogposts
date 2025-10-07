# Post Execution Debugging

An example how to use post-execution debugging with MLE/JavaScript in SQL Developer Extension for VSCode 25.3.0 and later.

If you want to try this out yourself, you need to

- Have an Oracle Database 23ai available.
    - Oracle Database Free is perfect for this, especially when running in a container
    - You can use any of the other database editions, too
- Create an account to deploy the code against
    - The easiest way is to use Gerald Venzl's Database Free image and define an APP_USER
    - See [the database directory](../database/README.md) for examples

Once created, connect to the database schema and deploy the application

```sql
project gen-artifact
project deploy -file artifact/
```