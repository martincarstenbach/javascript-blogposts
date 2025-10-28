# JavaScript Blog Posts

This directory contains all the code used in my JavaScript blog posts at <https://martincarstenbach.com>. These are mainly static, eg you'll find a list of (node, typescript, Oracle, ...) versions a given project was tested against. As time progresses the contents might not be applicable to the then current versions, in which case I'd appreciate if you could let me know by creating an issue. In case I don't get around to update subdirectories there might be security problems with outdated NPM packages.

> [!IMPORTANT]  
> This project refers to other third party modules. Please refer each referenced project’s GitHub project site for more details about its license and use implications. It is assumed your legal and IT Security departments (as well as any other party) agreed that using the module in your code is safe and compliant with your license. Using 3rd party code in your application typically requires specific compliance steps to be completed which are out of the scope

## Overview

| Project | Contents | Link to post |
| -- | -- | -- |
| [database](database/README.md) | {Podman,Docker} compose files to create a new Oracle Database Free 23ai instance as well as an ORDS and/or APEX environment | |
| [express-mle-javascript](./express-mle-javascript/readme.md) | Short example showing how to combine node-express and MLE/JavaScript | [Blog Post](https://martincarstenbach.com/2025/01/17/node-express-mle-javascript-example/) |
| [graphql-simplified](./graphql-simplified/README.md) | Simplified version of the original GraphQL Example | [Blog Post](https://martincarstenbach.com/2024/06/06/creating-a-graphql-endpoint-within-the-database-redux/) |
| [mle-typescript](./mle-typescript/README.md) | Example for migrating from plain JavaScript to TypeScript to make use of type-checking and linting | [Readme](./mle-typescript/README.md) |
| [mle-sqlcl-liquibase](./mle-sqlcl-liquibase/readme.md) | DEPRECATED Example how to use `runOraclescript` to create MLE/JavaScript modules. SQLcl now supports MLE modules natively | [Blog Post](https://martincarstenbach.com/2024/08/15/create-mle-javascript-modules-using-liquibase/) |
| [timeout-polyfill](./timeout-polyfill/readme.md) | An example how to provide a polyfill for `setTimeout()` in MLE 23.8 | [Blog Post](https://martincarstenbach.com/2025/05/22/multilingual-engine-polyfill-timeouts-and-intervals/) |
| [post-execution-debugging](post-execution-debugging/README.md) | An example how to use the new post-execution-debugging feature introduced in SQLDeveloper Extension for VSCode 25.3.0 | [Blog post](https://martincarstenbach.com/2025/10/07/intro-to-post-execution-debugging-in-sql-developer-for-vscode/) |
| [abstract-data-types](mle-abstract-data-types/readme.md) | An example how to use PL/SQL Records and Collections in MLE/JavaScript | [Blog Post](https://martincarstenbach.com/2025/10/28/whats-new-with-mle-23-26-0-support-for-pl-sql-collections-and-records-pt-1/) |

## Disclaimer

As I said before, this isn't official code, and whilst I tried my best to ensure it works, there is no guarantee. I also didn't check for any licenses that you might have to comply with so please do all the due-diligence on your end to ensure the examples in this repository are in line with your company's policies. And last but not least, always ensure you check for security vulnerabilities!