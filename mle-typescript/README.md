# Linting MLE JavaScript Modules in Continuous Integration Pipelines

The code has been updated to avoid the following issues with ESLint:

```
npm install --save-dev eslint @eslint/js @types/eslint__js typescript typescript-eslint
npm WARN deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
npm WARN deprecated rimraf@3.0.2: Rimraf versions prior to v4 are no longer supported
npm WARN deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported

added 132 packages in 2s

35 packages are looking for funding
  run `npm fund` for details
```

This [seems to be very hard to fix](https://github.com/vercel/next.js/issues/66239) which is why the linting portion switched to [biome](https://bestofjs.org/projects/biome).

## Database Setup

The following SQL code must be executed in the database

```sql
CREATE TABLE j_purchaseorder
  (id          VARCHAR2 (32) NOT NULL PRIMARY KEY,
   date_loaded TIMESTAMP (6) WITH TIME ZONE,
   po_document JSON);

INSERT INTO j_purchaseorder
  VALUES (
    SYS_GUID(),
    to_date('30-DEC-2014'),
    '{"PONumber"             : 1600,
      "Reference"            : "ABULL-20140421",
      "Requestor"            : "Alexis Bull",
      "User"                 : "ABULL",
      "CostCenter"           : "A50",
      "ShippingInstructions" :
        {"name"    : "Alexis Bull",
         "Address" : {"street"  : "200 Sporting Green",
                      "city"    : "South San Francisco",
                      "state"   : "CA",
                      "zipCode" : 99236,
                      "country" : "United States of America"},
         "Phone"   : [{"type" : "Office", "number" : "909-555-7307"},
                      {"type" : "Mobile", "number" : "415-555-1234"}]},
      "Special Instructions" : null,
      "AllowPartialShipment" : true,
      "LineItems"            :
        [{"ItemNumber" : 1,
          "Part"       : {"Description" : "One Magic Christmas",
                          "UnitPrice"   : 19.95,
                          "UPCCode"     : 13131092899},
          "Quantity"   : 9.0},
         {"ItemNumber" : 2,
          "Part"       : {"Description" : "Lethal Weapon",
                          "UnitPrice"   : 19.95,
                          "UPCCode"     : 85391628927},
          "Quantity"   : 5.0}]}');

INSERT INTO j_purchaseorder
  VALUES (
    SYS_GUID(),
    to_date('30-DEC-2014'),
    '{"PONumber"             : 672,
      "Reference"            : "SBELL-20141017",
      "Requestor"            : "Sarah Bell",
      "User"                 : "SBELL",
      "CostCenter"           : "A50",
      "ShippingInstructions" : {"name"    : "Sarah Bell",
                                "Address" : {"street"  : "200 Sporting Green",
                                             "city"    : "South San Francisco",
                                             "state"   : "CA",
                                             "zipCode" : 99236,
                                             "country" : "United States of America"},
                                "Phone"   : "983-555-6509"},
      "Special Instructions" : "Courier",
      "LineItems"            :
        [{"ItemNumber" : 1,
          "Part"       : {"Description" : "Making the Grade",
                          "UnitPrice"   : 20,
                          "UPCCode"     : 27616867759},
          "Quantity"   : 8.0},
         {"ItemNumber" : 2,
          "Part"       : {"Description" : "Nixon",
                          "UnitPrice"   : 19.95,
                          "UPCCode"     : 717951002396},
          "Quantity"   : 5},
         {"ItemNumber" : 3,
          "Part"       : {"Description" : "Eric Clapton: Best Of 1981-1999",
                          "UnitPrice"   : 19.95,
                          "UPCCode"     : 75993851120},
          "Quantity"   : 5.0}]}');
```

## Example usage

As soon as the TypeScript file has been transpiled to JavaScript it can be loaded as a MLE module, and used.

```sql
create or replace mle module blogpost_module
language javascript as

// contents of the transpiled file here
```

With the module created, you need to add a call specification: to make the JavaScript function available in SQL and PL/SQL

```sql
create or replace procedure process_purchase_order(
    po_number number
) as mle module blogpost_module
signature 'processPurchaseOrder';
```

Let's try it!

```sql
SELECT
    JSON_VALUE(po_document, '$.lastUpdate' DEFAULT 'does not yet exist' ON EMPTY) last_update
FROM
    j_purchaseorder po
WHERE
    po.po_document.PONumber = 672
/

LAST_UPDATE           
_____________________ 
does not yet exist

BEGIN
  process_purchase_order(672);
end;
/

SELECT
    JSON_VALUE(
      po_document,
      '$.lastUpdate' 
      DEFAULT 'does not yet exist' ON EMPTY
    ) last_update
FROM
    j_purchaseorder po
WHERE
    po.po_document.PONumber = 672
/

LAST_UPDATE                 
___________________________ 
2024-06-06T15:21:35.700Z
```

That was it - nice!
