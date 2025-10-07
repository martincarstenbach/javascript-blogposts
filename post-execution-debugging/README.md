# Post Execution Debugging

An example how to use [post-execution debugging](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/post-execution-debugging.html) with MLE/JavaScript in SQL Developer Extension for VSCode 25.3.0 and later.

If you want to try this out yourself, you need to

- Have an Oracle Database 23ai available.
    - [Oracle Database Free](https://www.oracle.com/database/free/) is perfect for this, especially when running in a container
    - You can of course use any of the other database editions, too, such as an [Always Free Autonomous Database (Serverless)](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/autonomous-always-free.html)
- Create an account to deploy the code against
    - The easiest way is to use Gerald Venzl's Database Free image and define an APP_USER
    - See [the database directory](../database/README.md) for examples

Once created, connect to the database schema and deploy the application

```sql
project gen-artifact
project deploy -file artifact/post-execution-debugging-1.0.0.zip
```

Now you're ready to try post-execution debugging. The [blog post](https://martincarstenbach.com/2025/10/07/intro-to-post-execution-debugging-in-sql-developer-for-vscode/) has all the details.
