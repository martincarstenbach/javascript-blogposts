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