# Multilingual Engine/Typescript example

This little project demonstrates the workflow using [Typescript](https://www.typescriptlang.org/) to develop server-side JavaScript code, powered by [Multilingual Engine (MLE)](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/). It features a little application allowing multiple people to organise their to do lists. Each user can create categories for their lists. Each item on the to do list can have a priority associated with it.

The Typescript code in this example provides an API you can invoke, for example via [Oracle REST Data Services (ORDS)](https://www.oracle.com/ords) or node-express to perform typical CRUD operations for the main tables (users, categories, todo_list).

## Development workflow

Broadly speaking you follow these steps when writing MLE code in Typescript:

- You develop your Typescript code locally using Visual Studio Code (VSCode) or a comparable editor
- The IDE should offer convenience features like type checking, linting, formatting, ...
- Thanks to the [MLE Type Declarations](https://oracle-samples.github.io/mle-modules/) you write more robust code that is less prone to runtime errors
- Once the code is ready for local testing, use `npm run deploy` to deploy it

The following sections provide additional details concerning these concepts.

### Editor

Your editor is the primary tool for writing Typescript. [Visual Studio Code](https://code.visualstudio.com/) is a great choice because it has strong support for the [Oracle Database](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer). It also features excellent Typescript (and JavaScript) support. If you decide to use VSCode to write server-side Typescript code, you may want to improve the developer experience by

- using [MLE Type Declarations](https://oracle-samples.github.io/mle-modules/)
- add extensions to VSCode, like
  - Oracle SQL Developer Extension for VSCode
  - prettier, biome, etc. for code formatting
  - eslint, biome, etc. for linting your code
  - Docker/Podman for your compose file management and local container management
  - others
- use the built-in terminal to run commands

When you are done writing your Typescript code you need to transpile it to JavaScript in preparation of the deployment.

### Database Deployment

This project provides you with the _build_ script to transpile Typescript, storing the result in `dist`. If you want do transpile and deploy in one step, use the `deploy` script. As soon as [SQLcl](https://www.oracle.com/sqlcl) projects support MLE/JavaScript, this step will be overhauled and updated.

<details>
  <summary><tt>npm run deploy</tt></summary>

```
> deploy
> npx tsc && bash utils/deploy.sh

+++ pwd
++ basename /home/martin/devel/javascript/javascript-blogposts/mle-typescript
+ [[ mle-typescript != mle-typescript ]]
+ cp -v src/database/01_users.sql src/database/02_categories.sql src/database/03_todo_list.sql src/database/04_todo_package.sql dist
'src/database/01_users.sql' -> 'dist/01_users.sql'
'src/database/02_categories.sql' -> 'dist/02_categories.sql'
'src/database/03_todo_list.sql' -> 'dist/03_todo_list.sql'
'src/database/04_todo_package.sql' -> 'dist/04_todo_package.sql'
+ cp -v src/database/controller.xml dist
'src/database/controller.xml' -> 'dist/controller.xml'
+ cp -v utils/deploy.sql dist
'utils/deploy.sql' -> 'dist/deploy.sql'
+ cd dist
+ /opt/oracle/sqlcl/bin/sql /nolog @deploy


SQLcl: Release 24.3 Production on Fri Feb 28 16:53:55 2025

Copyright (c) 1982, 2025, Oracle.  All rights reserved.

Connected.
--Starting Liquibase at 2025-02-28T16:53:55.996759773 (version 4.25.0.305.0400 #0 built at 2024-10-31 21:25+0000)
Database is up to date, no changesets to execute

UPDATE SUMMARY
Run:                          0
Previously run:               3
Filtered out:                 0
-------------------------------
Total change sets:            3



Operation completed successfully.

MLE Module todos_module created

MLE env TODOS_ENV created.

Disconnected from Oracle Database 23ai Free Release 23.0.0.0.0 - Develop, Learn, and Run for Free
Version 23.6.0.24.10
```
</details>


This command will create the example database objects and deploy the transpiled JavaScript code as MLE module.

### Typescript and MLE Type Declarations

Typescript is a superset of JavaScript and it offers many advantages for developers. 

MLE Type Declarations greatly improve the developer experience. As the name suggests, Typescript adds types to JavaScript. With that it's possible to find many bugs while you are writing your code.

The use of Typescript requires a configuration file (`tsconfig.json`). This project comes with a suitable file you can use as the basis for your own code.

### Unit Tests

This project also features unit tests you can run. Adding unit tests along new features is a much needed practice, especially when using JavaScript.

<details>
  <summary><tt>npm run test</tt></summary>

This needs completing

<details>

This command runs all the unit tests and prints the output on screen.

### Linting Code

This project uses [biome.js](https://biomejs.dev/) for linting, but this is merely one option among many. ESLint is another popular tool in the JavaScript ecosystem, and there are many additional ones out for you to try.

<details>
  <summary><tt>npm run lint</tt></summary>

```

> lint
> npx biome lint --verbose src/typescript

Checked 1 file in 1106µs. No fixes applied.
 VERBOSE  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ℹ Files processed:
  
  - src/typescript/todos.ts
  

 VERBOSE  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ℹ Files fixed:
  
  ⚠ The list is empty.
```
</details>

This command will tell you if your source file(s) adhere to your coding standards.# Example Template

The introduction summarizes the purpose and function of the project, and should be concise (a brief paragraph or two). This introduction may be the same as the first paragraph on the project page.

For a full description of the module, visit the
[project page](https://www.oracle.com).

Submit bug reports and feature suggestions, or track changes in the
[issue queue](https://www.oracle.com).


## Table of contents (optional)

- Requirements
- Installation
- Configuration
- Troubleshooting
- FAQ
- Maintainers


## Requirements (required)

This project requires the following:

- [Hard Work](https://www.noMorePlay.com)


## Installation (required, unless a separate INSTALL.md is provided)

Install as you would normally install.

## Configuration (optional)

## Troubleshooting (optional)

## FAQ (optional)

**Q: How do I write a README?**

**A:** Follow this template. It's fun and easy!

## Maintainers (optional)


## For more information about SQLcl Projects:
Reach out to the SQLcl Project Extension documentation by visiting the [Database Application CI/CD Doc Link](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/24.3/sqcug/database-application-ci-cd.html).
