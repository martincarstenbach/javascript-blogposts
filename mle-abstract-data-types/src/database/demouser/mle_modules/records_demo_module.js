 
import "mle-js-fetch";

export async function processProductData(productInfo) {

    if (Object.keys(productInfo).length === 0) {
        throw new Error("Input data cannot be empty");
    }

    if (typeof productInfo !== 'object' || Array.isArray(productInfo)) {
        throw new Error("Input data must be a non-array object");
    }

    // check downstream system for product availability and validation
    // this is defined in REST_HANDLER_MODULE
    try {
        const response = await fetch('http://some-ords:8080/ords/demouser/api/v1/validate/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(productInfo)
        });

        if (!response.ok) {
            throw new Error(`Downstream validation failed, server responded with status ${response.status}`);
        }

        const data = await response.json();
        console.log(`status: ${response.status} message: ${data.message}`);
    } catch (error) {
        console.error(`Error validating productInfo: ${error}`);
    }
}
