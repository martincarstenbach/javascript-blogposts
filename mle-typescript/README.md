Continuous Integration (CI) is the process of automatically building and testing your application's code each time a developer pushes a commit to a remote source-code control repository like GitLab or GitHub. The use of CI is an integral part of DevOps and can be used to great effect: lead times (e.g. the time it takes from idea to shipping) can be reduced and thanks to automated unit and integration testing, error rates typically drop as well.

In most cases a CI server coordinates the execution of tests using a so-called CI Pipeline. CI Pipelines are typically defined as code, and checked into the same Git repository as the application's code. Most CI servers accept YAML syntax to define jobs and associate them to stages such as linting, build, test, deploy.

One of the golden rules in CI is the "keep the pipeline green", in other words should the CI Pipeline encounter any errors work needs to stop and all hands must jointly resolve the problem before further commits can be pushed. It is easy to see that errors should be avoided to prevent "soft outages" - times during which development work is at best slowed down, in the worst case it can come to a halt for a period of time.

## Local Tests

Testing code locally before committing/pushing it to the remote Git repository is very important to avoid problems with the CI Pipeline's execution. This article concerns itself with local tests of [JavaScript modules used with Oracle Database 23c Free](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/index.html). JavaScript Modules are an interesting new database feature allowing developers to process data where they live using one of the most popular programming languages. With the addition of JavaScript Oracle Database features 3 programming languages (PL/SQL and Java being the other 2). The feature enabling JavaScript support on Linux x86-64 in Oracle Database 23c Free is known as Multilingual Engine (MLE).

Using [`eslint` with its TypeScript plugin](https://typescript-eslint.io/) it possible to thoroughly check MLE modules locally before submitting them to the database. This approach does a lot more than what [`eslint`](https://eslint.org) would be able to do on its own. On the downside it is a little more involved than writing pure JavaScript code, but using TypeScript features pays off big time in the end. Not only is it possible to check for syntax errors, using the TypeScript declaration you can even use type checks in the form of "is this parameter I'm passing to a function correct?"

The MLE team has provided the TypeScript declarations used by all MLE built-in modules on NPM, documentation can be found on [GitHub](https://oracle-samples.github.io/mle-modules/).

> **NOTE:** The use of `eslint` is merely an example, not an endorsement for the tool. There are many more linters available to developers. Always ensure you are comfortable working with a given piece of software, and that you are (license, ...) compliant.

## Versions Used

The following versions were used in the creation of this article:
```
$ npm list
mle@ /home/martin/devel/typescript/mle
├── @typescript-eslint/eslint-plugin@6.9.1
├── @typescript-eslint/parser@6.9.1
├── eslint@8.53.0
├── mle-js@23.3.0
└── typescript@5.2.2
$ node --version
v20.9.0

Oracle Database 23c Free Release 23.0.0.0.0 - Develop, Learn, and Run for Free, Version 23.3.0.23.09
```

## Initial JavaScript Example

For the sake of demonstration let's assume someone created the following MLE JavaScript module in their favourite editor, saved as `src/blogpost.js`.

```javascript
/**
 * Update the "lastUpdated" field in a purchase order, adding it if it does not 
 * yet exist. Uses the example defined in the JSON Developer's Guide, chapter 4 
 * Examples 4-1 and 4-3
 * @param {object} purchaseOrder - the PO to update 
 * @param {string} lastUpdate - a string representation of a date (YYYY-MM-DDThh:mm:ss)
 * @returns {object} the updated purchaseOrder
 */
function setLastUpdatedDate(purchaseOrder, lastUpdate) {

    if (purchaseOrder === undefined) {
        throw Error("unknown purchase order");
    }

    if (lastUpdate = undefined) {
        lastUpdate = new Date().toISOString();
    }

    console.log(`last update set to ${lastUpdate}`);

    purchaseOrder.lastUpdate = lastUpdate;

    return purchaseOrder;
}

/**
 * Use vanilla JavaScript to validate a PurchaseOrder. This could have been
 * done with JSON schema validation as well but would have been harder to
 * lint using eslint.
 * @param {object} purchaseOrder - the PO to validate
 * @returns {boolean} true if the PO could be successfully validated, false if not
 */
function validatePO(purchaseOrder) {

    // a PO must contain line items
    if (purchaseOrder.LineItems.length <= 0) {
        return false;
    }

    // a PO must contain shipping instructions
    if (purchaseOrder.ShippingInstructions === undefined) {
        return false;
    }

    return true;
}

/**
 * Fetch a PurchaseOrder from the database and process it. Store the last modification
 * timestamp alongside
 * @param {number} poNumber - the PONumber as stored in j_purchaseorder.po_document.PONumber 
 */
export function processPurchaseOrder(poNumber) {

    const result = session.execute(
        `SELECT
            po.po_document as PO
        FROM
            j_purchaseorder po
        WHERE
            po.po_document.ponumber = :1`,
        [poNumber],
        " thisIsAnIncorrectParameter "
    );

    // ensure the PO exists
    if (result.rows === undefined) {
        throw Error(`could not find a PO for PO Number ${poNumber}`);
    } else {
        const myPO = result.rows[0].PO;
    }

    // make sure the PO is valid
    if (!validatePO(myPO)) {
        throw Error(`Purchase Order ${poNumber} is not a valid PO`);
    }

    // do some fancy processing with the PO

    // indicate when the last operation happened
    myPO = setLastUpdatedDate(myPO, undefined);

    result = session.execute(
        `UPDATE j_purchaseorder po
        SET
            po.po_document = :myPO
        WHERE
            po.po_document.PONumber = :poNumber`,
        {
            myPO: {
                dir: oracledb.BIND_IN,
                type: oracledb.DB_TYPE_JSON,
                val: myPO
            },
            poNumber: {
                dir: oracledb.BIND_IN,
                type: oracledb.NUMBER,
                val: poNumber
            }
        }
    );

    if (result.rowsAffected != 1) {
        throw Error(`unable to persist purchase order ${poNumber}`);
    }
}
```

Before submitting the code to the database for testing the developer should ensure the code doesn't have any errors. The example has been chosen to put emphasis on the fact that it&#039;s very hard to ensure code quality by merely eyeballing the text ;)

## Improving Code Quality

Converting the above code to TypeScript provides lots of benefits to developers:

- Type declarations available for all MLE modules add a safety net to the code.
- Linting TypeScript adds even more checks to ensure the transpiled code is good to go.

The remainder of this article is concerned with the transition to TypeScript and correction of the errors encountered.

### Installing MLE JavaScript Type Declarations 

As per the [MLE module documentation](https://oracle-samples.github.io/mle-modules/) the first step is to install the `mle-js` module from NPM. This module contains the type declarations for all built-in modules used later. The following instructions are relative to the project root directory.

```shell
$ npm install mle-js --save-dev
```

### Installing TypeScript and ESLint

In the next step you need to decide which linter to use, this post focuses on `eslint` with its TypeScript plugin. 

```shell
npm install \
eslint \
@typescript-eslint/parser \
@typescript-eslint/eslint-plugin \
typescript --save-dev
```

See above for a list of packages this installed at the time of writing.

### Creating a basic linter configuration

ESLint needs a [configuration file](https://typescript-eslint.io/linting/configs), the following example is a good starting point for your own `.eslintrc` (to be placed in the project root)

```json
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "project": true,
    "tsconfigRootDir": "__dirname"
  },
  "plugins": [
    "@typescript-eslint"
  ],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking"
  ],
  "rules": {
    "no-const-assign": "error",
    "no-console": "error"
  }
}
```

The example is taken from the [documentation](https://typescript-eslint.io/linting/configs) and extended for the use with MLE JavaScript modules.

## JavaScript to TypeScript

The first step in the conversion from JavaScript to Typescript is to rename the source file to `blogpost.ts`. Next you need to create a `tsconfig.json` file. The following is a minimal file instructing TypeScript to transpile JavaScript code with the latest version of JavaScript supported by Oracle Database 23c Free (at the time of writing):

```json
{
    "compilerOptions": {
        "target": "ES2022",
        "module": "ES2022",
        "rootDir": "./src", 
        "outDir": "./dist",
        "noEmitOnError": true,
        "esModuleInterop": true,
        "forceConsistentCasingInFileNames": true,
        "strict": true,
        "skipLibCheck": true
    }
}
```

TypeScript code must be told about the MLE JavaScript type definitions found in `mle-js`. This is done using a triple-slash directive to be added at the first line of the source code file, `blogpost.ts`:

```javascript
/// <reference types="mle-js" />

/**
 * Update the "lastUpdated" field in a purchase order, adding it if it does not

[... more code ...]
```

With the type declarations made available to the source file you are ready to perform the linting process. As per [TypeScript eslint issue 352](https://github.com/typescript-eslint/typescript-eslint/issues/352) `eslint` does not concern itself with type checking. This is done by TypeScript's `tsc` command line utility. Therefore 2 passes are required:

1. Syntax checks using `eslint`
1. Type checks using `tsc`

### Linting

```
$ npx eslint .

/home/martin/devel/typescript/mle/src/blogpost.ts
   17:9   error  Expected a conditional expression and instead saw an assignment  no-cond-assign
   17:9   error  Unexpected constant condition                                    no-constant-condition
   21:5   error  Unexpected console statement                                     no-console
   23:5   error  Unsafe assignment of an `any` value                              @typescript-eslint/no-unsafe-assignment
   23:19  error  Unsafe member access .lastUpdate on an `any` value               @typescript-eslint/no-unsafe-member-access
   25:5   error  Unsafe return of an `any` typed value                            @typescript-eslint/no-unsafe-return
   38:23  error  Unsafe member access .LineItems on an `any` value                @typescript-eslint/no-unsafe-member-access
   43:23  error  Unsafe member access .ShippingInstructions on an `any` value     @typescript-eslint/no-unsafe-member-access
   57:11  error  Unsafe assignment of an `any` value                              @typescript-eslint/no-unsafe-assignment
   57:20  error  Unsafe call of an `any` typed value                              @typescript-eslint/no-unsafe-call
   57:28  error  Unsafe member access .execute on an `any` value                  @typescript-eslint/no-unsafe-member-access
   69:16  error  Unsafe member access .rows on an `any` value                     @typescript-eslint/no-unsafe-member-access
   72:15  error  Unsafe assignment of an `any` value                              @typescript-eslint/no-unsafe-assignment
   72:15  error  'myPO' is assigned a value but never used                        @typescript-eslint/no-unused-vars
   72:29  error  Unsafe member access .rows on an `any` value                     @typescript-eslint/no-unsafe-member-access
   83:5   error  Unsafe assignment of an `any` value                              @typescript-eslint/no-unsafe-assignment
   85:5   error  'result' is constant                                             no-const-assign
   85:5   error  Unsafe assignment of an `any` value                              @typescript-eslint/no-unsafe-assignment
   85:14  error  Unsafe call of an `any` typed value                              @typescript-eslint/no-unsafe-call
   85:22  error  Unsafe member access .execute on an `any` value                  @typescript-eslint/no-unsafe-member-access
   93:17  error  Unsafe assignment of an `any` value                              @typescript-eslint/no-unsafe-assignment
   93:31  error  Unsafe member access .BIND_IN on an `any` value                  @typescript-eslint/no-unsafe-member-access
   94:17  error  Unsafe assignment of an `any` value                              @typescript-eslint/no-unsafe-assignment
   94:32  error  Unsafe member access .DB_TYPE_JSON on an `any` value             @typescript-eslint/no-unsafe-member-access
   95:17  error  Unsafe assignment of an `any` value                              @typescript-eslint/no-unsafe-assignment
   98:17  error  Unsafe assignment of an `any` value                              @typescript-eslint/no-unsafe-assignment
   98:31  error  Unsafe member access .BIND_IN on an `any` value                  @typescript-eslint/no-unsafe-member-access
   99:17  error  Unsafe assignment of an `any` value                              @typescript-eslint/no-unsafe-assignment
   99:32  error  Unsafe member access .NUMBER on an `any` value                   @typescript-eslint/no-unsafe-member-access
  100:17  error  Unsafe assignment of an `any` value                              @typescript-eslint/no-unsafe-assignment
  105:16  error  Unsafe member access .rowsAffected on an `any` value             @typescript-eslint/no-unsafe-member-access

✖ 31 problems (31 errors, 0 warnings)
```

Right, that's quite a bunch of problems. You can see where they occurred in the file and you are conveniently provided with the rule as well. 

The linter correctly detected that I was assigning a value in an if statement, a common error:

```javascript
    if (lastUpdate = undefined) {
        lastUpdate = new Date().toISOString();
    }
```

It doesn't make a lot of sense to print to the console in server-side code, the statement in line 21 should be removed. [Post-execution Debugging](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/post-execution-debugging.html) can be used instead.

`eslint` also told me that I shouldn't assign a value to a constant once it's been initialised (line 85). 

There are a few errors related to JavaScript code that hasn't yet been annotated with types. Let's see what the TypeScript compiler has to say next:

### Type Checking

Similarly there are a lot of problems with the JavaScript code:

```
$ npx tsc --noEmit
src/blogpost.ts:35:21 - error TS7006: Parameter 'purchaseOrder' implicitly has an 'any' type.

35 function validatePO(purchaseOrder) {
                       ~~~~~~~~~~~~~

src/blogpost.ts:55:38 - error TS7006: Parameter 'poNumber' implicitly has an 'any' type.

55 export function processPurchaseOrder(poNumber) {
                                        ~~~~~~~~

src/blogpost.ts:65:9 - error TS2559: Type '" thisIsAnIncorrectParameter "' has no properties in common with type 'IExecuteOptions'.

65         " thisIsAnIncorrectParameter "
           ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

src/blogpost.ts:76:21 - error TS2304: Cannot find name 'myPO'.

76     if (!validatePO(myPO)) {
                       ~~~~

src/blogpost.ts:83:5 - error TS2304: Cannot find name 'myPO'.

83     myPO = setLastUpdatedDate(myPO, undefined);
       ~~~~

src/blogpost.ts:83:31 - error TS2304: Cannot find name 'myPO'.

83     myPO = setLastUpdatedDate(myPO, undefined);
                                 ~~~~

src/blogpost.ts:83:37 - error TS2345: Argument of type 'undefined' is not assignable to parameter of type 'string'.

83     myPO = setLastUpdatedDate(myPO, undefined);
                                       ~~~~~~~~~

src/blogpost.ts:85:5 - error TS2588: Cannot assign to 'result' because it is a constant.

85     result = session.execute(
       ~~~~~~

src/blogpost.ts:95:22 - error TS2304: Cannot find name 'myPO'.

95                 val: myPO
                        ~~~~


Found 9 errors in the same file, starting at: src/blogpost.ts:35
```

This is indeed sufficient information to get started. Let's port the code to TypeScript to get rid of the errors

## Fixing the code

Based on the output provided by `eslint` and `tsc` it's possible to create a much better, more type-safe variant of the JavaScript example shown previously. In addition to fixing the JavaScript code problems, Type interfaces for the PurchaseOrder allow the compile to ensure the computation in `processPurchaseOrder()` are correct.


```typescript
/// <reference types="mle-js" />

/**
 * Stub interface, for demostration purpose only, should be fleshed out to 
 * reflect all data as per Example 4-3 in chapter 4 of the JSON Developer's
 * Guide
 */
interface ILineItem {
    ItemNumber: number,
    Part: string,
    Quantity: number
}

interface IShippingInstructions {
    name: string,
    address: string,
    phone: string
}

interface IPurchaseOrder {
    PONumber: number,
    lastUpdate: string,
    LineItems: ILineItem[],
    ShippingInstructions: IShippingInstructions[]
}

/**
 * Update the "lastUpdated" field in a purchase order, adding it if it does not 
 * yet exist. Uses the example defined in the JSON Developer's Guide, chapter 4 
 * Examples 4-1 and 4-3
 * @param {object} purchaseOrder - the PO to update 
 * @param {string} lastUpdate - a string representation of a date (YYYY-MM-DDThh:mm:ss)
 * @returns {object} the updated purchaseOrder
 */
function setLastUpdatedDate(purchaseOrder: IPurchaseOrder, lastUpdate: string): IPurchaseOrder {

    if (purchaseOrder === undefined) {
        throw new Error("unknown purchase order");
    }

    if (lastUpdate === undefined || lastUpdate === "") {
        lastUpdate = new Date().toISOString();
    }

    purchaseOrder.lastUpdate = lastUpdate;

    return purchaseOrder;
}

/**
 * Use vanilla JavaScript to validate a PurchaseOrder. This could have been
 * done with JSON schema validation as well but would have been harder to
 * lint using eslint.
 * @param {object} purchaseOrder - the PO to validate
 * @returns {boolean} true if the PO could be successfully validated, false if not
 */
function validatePO(purchaseOrder: IPurchaseOrder): boolean {

    // a PO must contain at least 1 line item
    if (purchaseOrder.LineItems === undefined) {
        return false;
    }

    if (purchaseOrder.LineItems.length <= 0) {
        return false;
    }

    // a PO must contain shipping instructions
    if (purchaseOrder.ShippingInstructions === undefined) {
        return false;
    }

    if (purchaseOrder.ShippingInstructions.length <= 0) {
        return false;
    }

    // more checks]

    // if everything went ok, the PO has been successfully validated
    return true;
}

/**
 * Fetch a PurchaseOrder from the database and process it. Store the last modification
 * timestamp alongside
 * @param {number} poNumber - the PONumber as stored in j_purchaseorder.po_document.PONumber 
 */
export function processPurchaseOrder(poNumber: IPurchaseOrder["PONumber"]) {

    let result = session.execute(
        `SELECT
            po.po_document as PO
        FROM
            j_purchaseorder po
        WHERE
            po.po_document.ponumber = :1`,
        [ poNumber ]
    );

    // ensure the PO exists
    if (result.rows === undefined) {
        throw new Error(`could not find Purchase Order ${poNumber}`);
    }
    
    // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
    let myPO = result.rows[0].PO as IPurchaseOrder;
    

    // make sure the PO is valid
    if (! validatePO(myPO)) {
        throw new Error(`Purchase Order ${poNumber} failed validation`);
    }

    // do some fancy processing with the PO ... then:
    // indicate when the last operation happened
    myPO = setLastUpdatedDate(myPO, "");

    result = session.execute(
        `UPDATE j_purchaseorder po
        SET
            po.po_document = :myPO
        WHERE
            po.po_document.PONumber = :poNumber`,
        {
            myPO: {
                dir: oracledb.BIND_IN,
                type: oracledb.DB_TYPE_JSON,
                val: myPO
            },
            poNumber: {
                dir: oracledb.BIND_IN,
                type: oracledb.DB_TYPE_NUMBER,
                val: poNumber
            }
        }
    );

    if (result.rowsAffected != 1) {
        throw new Error(`unable to persist purchase order ${poNumber}`);
    }
}
```

## Summary

The introduction of TypeScript allows for much better type checking. It also opens the door for linting code. Thankfully developers can use a wide variety of Integrated Development Environments (IDEs) supporting them in writing TypeScript code. Linting and type-checking typically happens while code is written, often limiting the number of errors during pipeline execution to 0