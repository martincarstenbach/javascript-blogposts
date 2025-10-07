
  CREATE OR REPLACE MLE MODULE "PURCHASE_ORDER_MODULE" 
   LANGUAGE JAVASCRIPT AS 
import { parseKeyValueString } from "utilities";

/**
 * Processes an order by parsing key-value string data and inserting it into the database.
 * Throws an error if input is not a non-null string or if parsed data is empty.
 *
 * @param {string} orderData - The input string containing order key-value pairs.
 * @returns {boolean} True if the order was inserted successfully, false otherwise.
 * @throws {TypeError} If the input is not a non-null string.
 * @throws {Error} If the parsed order data is empty.
 */
export function processOrder(orderData) {
	if (typeof orderData !== "string" || orderData === null) {
		throw new TypeError("Input must be a non-null string");
	}

	// remember that parseKeyValueString is defined in the utilities package
	const orderDataJSON = parseKeyValueString(orderData);

	// Check if orderDataJSON is an empty object
	if (!orderDataJSON || Object.keys(orderDataJSON).length === 0) {
		throw new Error("Parsed order data is empty");
	}

	// insert data using the MLE/JavaScript SQL driver
	const result = session.execute(
		`
        insert into orders (
            order_date,
            order_mode,
            customer_id,
            order_status, 
            order_total,
            sales_rep_id,
            promotion_id
        )
        select 
            jt.* 
        from
            json_table(:orderDataJSON, '$' columns
                order_date timestamp path '$.order_date',
                order_mode           path '$.order_mode',
                customer_id          path '$.customer_id', 
                order_status         path '$.order_status',
                order_total          path '$.order_total', 
                sales_rep_id         path '$.sales_rep_id',
                promotion_id         path '$.promotion_id'
            ) jt`,
		{
			orderDataJSON: {
				val: orderDataJSON,
				type: oracledb.DB_TYPE_JSON,
			},
		},
	);

	if (result.rowsAffected === 1) {
		return true;
	} else {
		return false;
	}
}
/


-- sqlcl_snapshot {"hash":"ea53576ba52f305b12a1ca835c118513c3e5c95a","type":"MLE_MODULE","name":"PURCHASE_ORDER_MODULE","schemaName":"DEMOUSER","sxml":""}