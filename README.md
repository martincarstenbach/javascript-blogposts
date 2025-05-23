# JavaScript Blog Posts

This directory contains all the code used in my JavaScript blog posts at <https://martincarstenbach.com>. These are mainly static, eg you'll find a list of (node, typescript, Oracle, ...) versions a given project was tested against. As time progresses the contents might not be applicable to the then current versions, in which case I'd appreciate if you could let me know by creating an issue. In case I don't get around to update subdirectories there might be security problems with outdated NPM packages.

> ALWAYS ensure you check the code for vulnerabilities and compliance with your project/license/team/...

## Overview

| Project | Contents | Link to post |
| -- | -- | -- |
| database | {Podman,Docker} compose files to create a new Oracle Database Free 23ai instance | |
| [express-mle-javascript](./express-mle-javascript/readme.md) | Short example showing how to combine node-express and MLE/JavaScript | [Blog Post](https://martincarstenbach.com/2025/01/17/node-express-mle-javascript-example/) |
| [mle-typescript](./mle-typescript/README.md) | Example for migrating from plain JavaScript to TypeScript to make use of type-checking and linting | [Readme](./mle-typescript/README.md) |
| [graphql-simplified](./graphql-simplified/README.md) | Simplified version of the original GraphQL Example | [Blog Post](https://martincarstenbach.com/2024/06/06/creating-a-graphql-endpoint-within-the-database-redux/) |
| [mle-sqlcl-liquibase](./mle-sqlcl-liquibase/readme.md) | Example how to use `runOraclescript` to create MLE/JavaScript modules | [Blog Post](https://martincarstenbach.com/2024/08/15/create-mle-javascript-modules-using-liquibase/) |
| [timeout-polyfill](./timeout-polyfill/readme.md) | An example how to provide a polyfill for `setTimeout()` in MLE 23.8 | [Blog Post](https://martincarstenbach.com/2025/05/22/multilingual-engine-polyfill-timeouts-and-intervals/) |

## Disclaimer

As I said before, this isn't official code, and whilst I tried my best to ensure it works, there is no guarantee. I also didn't check for any licenses that you might have to comply with so please do all the due-diligence on your end to ensure the examples in this repository are in line with your company's policies. And last but not least, always ensure you check for security vulnerabilities!