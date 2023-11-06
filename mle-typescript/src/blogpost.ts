/// <reference types="mle-js" />

/**
 * Stub interfaces, for demostration purpose only, should be fleshed out to 
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
export function processPurchaseOrder(poNumber: IPurchaseOrder["PONumber"]): void {

    let result = session.execute(
        `SELECT
            po.po_document as PO
        FROM
            j_purchaseorder po
        WHERE
            po.po_document.PONumber = :1`,
        [ poNumber ]
    );

    // ensure the PO exists
    if (result.rows === undefined || result.rows.length === 0) {
        throw new Error(`could not find Purchase Order ${poNumber}`);
    }
    
    // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
    let myPO = result.rows[0].PO as IPurchaseOrder;
    
    // make sure the PO is valid
    if (! validatePO(myPO)) {
        throw new Error(`Purchase Order ${poNumber} failed validation`);
    }

    // do some (imaginary) fancy processing with the PO ... 
    
    // ... then: indicate when the last operation happened
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