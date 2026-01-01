# Multilingual Engine/Typescript example

This little project demonstrates the workflow using [Typescript](https://www.typescriptlang.org/) to develop server-side JavaScript code, powered by [Multilingual Engine (MLE)](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/). It features a little application allowing multiple people to organise their to do lists. Each user can create categories for their lists. Each item on the to do list can have a priority associated with it. In the first iteration the database part is simulated. Time permitting a frontend will be added at a later stage.

The Typescript code in this example provides an API you can invoke, for example via [Oracle REST Data Services (ORDS)](https://www.oracle.com/ords) or [node-express](https://expressjs.com/) to perform typical CRUD operations for the main tables (users, categories, todo_list).

## Typescript development and Oracle AI Database 26ai

Broadly speaking you follow these steps when writing server-side code in Typescript:

- You develop your Typescript code locally using Visual Studio Code (VSCode) or a comparable editor
- The IDE should offer convenience features like type checking, linting, formatting, ...
- Thanks to the [MLE Type Declarations](https://oracle-samples.github.io/mle-modules/) you write more robust code that is less prone to runtime errors
- Once the code is ready for local testing, use `npm run deploy` to deploy it
- After the code has been deployed and tested locally it can be integrated into a CI/CD workflow

The following sections provide additional details concerning these concepts.

### Editor

Your editor is the primary tool for writing Typescript. [Visual Studio Code](https://code.visualstudio.com/) is a great choice because it has strong support for the [Oracle Database](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer). It also features excellent Typescript (and JavaScript) support. If you decide to use VSCode to write server-side Typescript code, you may want to improve the developer experience by

- using [MLE Type Declarations](https://oracle-samples.github.io/mle-modules/)
- creating short-lived branches to cover your ticket/work item
- add extensions to VSCode, like
  - Oracle SQL Developer Extension for VSCode
  - prettier, biome, etc. for code formatting
  - eslint, biome, etc. for linting your code
  - Docker/Podman for your compose file management and local container management
  - others
- use the built-in terminal to run commands

When you are done writing your Typescript code you need to transpile it to JavaScript in preparation of the deployment. This is done via `npm run deploy`. This "script" action is defined in `package.json`. As you can see the deployment is facilitated by `utils/deploy.sh`. At the time of writing the deployment was hard-coded, future iterations of the code will use a tool to deploy arbitrary modules.

All you local changes should be done it a separate, short-lived branch that ends its existence with the ticket. Branches shouldn't contain too many work items or you'll risk not being able to merge into main within the work day.

### Details concerning the workflow

Once you are happy with your changes to the Typescript file you can save the file and deploy the linted, formatted, and transpiled version into the database. According to the supplied `tsconfig.json` the Typescript compiler expects input files in `src/typescript`. The transpiled files will end up in `src/javascript` - the latter is excluded from Git via `.gitignore` since artefacts aren't supposed to be stored in version control.

In this simple example there is no need to bundle external, 3rd party libraries with your code, hence no mention of that step. More complex projects however can make use of module bundlers like [rollup](https://rollupjs.org/) or [esbuild](https://esbuild.github.io/) as well as many others.

Finally Oracle's [SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/download/) `mle create-module` command is invoked to deploy the transpiled module in the database. This is the point where you typically run unit tests and/or integration tests against the code, etc.

If everything has gone to plan it's time to follow the workflow as described by [SQLcl projects](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/25.4/sqcug/database-application-ci-cd.html). It's an opinionated workflow for database CI and has a proven track record for being robust and reliable.

### CI/CD pipeline

After local testing has successfully completed as per the above step you can integrate your new code into the CI workflow by committing and pushing the branch to your _origin_. A CI pipeline might clone your CI database, deploy the changes, and run unit tests against the change. Once that passes, you can create a merge (or pull request, depending on platform) and integrate into your main branch.

The entire process is discussed in [Implementing DevOps principles with Oracle Database](https://www.oracle.com/a/ocom/docs/database/implementing-devops-principles-with-oracle-database.pdf)

### Testing

If you would like to try the contents of this post for yourself, you first need a database to deploy against. Consider using the compose files in the project root's `database` directory. Once the database is up, create the `.env` file based on `.env.exemple`. Populate the values as appropriate.

Next up, install the necessary NPM packages using `npm install`, making sure you're in the `mle-typescript` directory.

Connect to your database using [SQLcl](https://oracle.com/sqlcl), and deploy the required tables. This repository uses plain Liquibase to do so, you should perhaps consider using SQLcl projects when working with your own code:

```
SQL> cd src/database
SQL> lb update -changelog-file controller.xml
```

Once the tables are deployed, you can deploy the Typescript code using `npm run deploy` (your current working directory has to be `mle-typescript` for this to work). Refer to the `utils/deploy.sh` script for details.

## Summary

Modern development techniques such as CI/CD and DevOps are applicable to database applications as much as they are to front-end applications. The stateful nature of database development requires some extra care, much of which is taken care off by the tools mentioned in this readme. Have fun coding!