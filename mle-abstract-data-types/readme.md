# Abstract Data Types in MLE/JavaScript

This repository contains code demonstrating the use of PL/SQL Records and Collections in MLE/JavaScript.

For a more verbose description of the code refer to the [corresponding blogpost](https://martincarstenbach.com/2025/10/28/whats-new-with-mle-23-26-0-support-for-pl-sql-collections-and-records-pt-1/).

## Setup

If you want to try the code in your playground/lab environment, you need [Oracle REST Data Services](https://www.oracle.com/database/technologies/appdev/rest.html) 25.3.0 or later and [Oracle AI Database 26ai](https://www.oracle.com/database/). It's easiest to follow the article by spinning up a couple of ephemeral container instances, like so:

```sh
cd database
podman compose -f compose-podman-ords-apex.yml -p database up -d
```

If you use docker, replace each occurrence of `podman` with `docker` and you should be fine. Once the database and ORDS have been instantiated, head over to the blog post to install Swingbench and perform the other tasks.

## Deployment

The application code is provided as a [SQLcl project](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/25.3/sqcug/database-application-ci-cd.html). You _must_ deploy the code using [SQLcl 25.3.0](https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-25.3.0.274.1210.zip) if you don't want to amend the project for the latest SQLcl release.

Change directory to `mle-abstract-data-types`. Next, connect to the demouser account in FREEPDB1, and generate the project artifact:

```
project gen-artifact

Your artifact has been generated adt-1.0.0.zip
```

Next up, deploy the artifact:

```
project deploy -verbose -debug -file artifact/adt-1.0.0.zip

UPDATE SUMMARY
Run:                          6
Previously run:               0
Filtered out:                 0
-------------------------------
Total change sets:            6

Liquibase: Update has been successful. Rows affected: 6

Produced logfile: sqlcl-lb-1761646841684.log

Operation completed successfully.


Log file(s) location: /home/martin/devel/javascript/javascript-blogposts/mle-abstract-data-types
Removing the decompressed artifact: /tmp/8f887293-28a0-4639-886d-011e04c5f9542078040239290346912...
SQL> lb history
--Starting Liquibase at 2025-10-28T11:20:55.676979214 using Java 21.0.8 (version 4.30.0 #0 built at 2025-04-01 10:24+0000)
Liquibase History for jdbc:oracle:thin:@(DESCRIPTION=(LOAD_BALANCE=ON)(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=freepdb1)))

+---------------+--------------------+------------------------------------------------------------------+------------------+---------------+-----+
| Deployment ID | Update Date        | Changelog Path                                                   | Changeset Author | Changeset ID  | Tag |
+---------------+--------------------+------------------------------------------------------------------+------------------+---------------+-----+
| 1646841793    | 10/28/25, 10:20 AM | abstract-data-types/demouser/mle_modules/records_demo_module.sql | DEMOUSER         | 1761590662309 |     |
+---------------+--------------------+------------------------------------------------------------------+------------------+---------------+-----+
| 1646841793    | 10/28/25, 10:20 AM | abstract-data-types/demouser/mle_modules/rest_handler_module.sql | DEMOUSER         | 1761590662337 |     |
+---------------+--------------------+------------------------------------------------------------------+------------------+---------------+-----+
| 1646841793    | 10/28/25, 10:20 AM | abstract-data-types/demouser/mle_envs/blogpost_env.sql           | DEMOUSER         | 1761590662271 |     |
+---------------+--------------------+------------------------------------------------------------------+------------------+---------------+-----+
| 1646841793    | 10/28/25, 10:20 AM | abstract-data-types/demouser/procedures/process_product_data.sql | DEMOUSER         | 1761590662366 |     |
+---------------+--------------------+------------------------------------------------------------------+------------------+---------------+-----+
| 1646841793    | 10/28/25, 10:20 AM | abstract-data-types/demouser/functions/get_product_details.sql   | DEMOUSER         | 1761590662241 |     |
+---------------+--------------------+------------------------------------------------------------------+------------------+---------------+-----+
| 1646841793    | 10/28/25, 10:20 AM | ords/demouser/ords.sql                                           | DEMOUSER         | 1761590662426 |     |
+---------------+--------------------+------------------------------------------------------------------+------------------+---------------+-----+
```

That's it - review the code and have fun!