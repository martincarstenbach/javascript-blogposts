
  CREATE OR REPLACE MLE MODULE "DEMOUSER"."REST_HANDLER_MODULE" 
   LANGUAGE JAVASCRIPT AS 
/**
 * Perform a mock validation on the input data. Input data is of type
 * soe.orderentry.prod_rec
 * 
 * @param {*} data the input data to validate
 * @returns true if the validation succeeds, false otherwise
 */
export function validate(data) {

    let result = {
        status: 200,
        message: `Validation succeeded for PRODUCT_ID ${data.PRODUCT_ID}`
    };
    
    // empty data is invalid
    if (Object.keys(data).length === 0) {
        result.status = 400;
        result.message = 'No data provided';
    }

    // data must be an object, not an array
    if (typeof data !== 'object' || Array.isArray(data)) {
        result.status = 400;
        result.message = 'Input is of wrong type';
    }

    // made-up rule: productId must be >= 100
    if (data.PRODUCT_ID < 100) {
        result.status = 422;
        result.message = 'Data failed validation: PRODUCT_ID must be >= 100';
    }


    if (data.PRODUCT_ID >= 100 && data.PRODUCT_ID < 200) {
        if (data.QUANTITY_ON_HAND < 10) {
            result.status = 422;
            result.message = `insufficient stock for PRODUCT_ID ${data.PRODUCT_ID}, found ${data.QUANTITY_ON_HAND}, minimum 10 required`;
        }
    }

    if (data.PRODUCT_ID >= 200 && data.PRODUCT_ID < 300) {
        if (data.QUANTITY_ON_HAND < 5) {
            result.status = 422;
            result.message = `insufficient stock for PRODUCT_ID ${data.PRODUCT_ID}, found ${data.QUANTITY_ON_HAND}, minimum 5 required`;
        }
    }

    return result;
}
/


-- sqlcl_snapshot {"hash":"439f9730b98bd430caf6db529a4a2adc2d3cf987","type":"MLE_MODULE","name":"REST_HANDLER_MODULE","schemaName":"DEMOUSER","sxml":""}