import { Jimp } from "jimp";

/**
 * This function uses JIMP to convert a coloured image to greyscale and returns
 * the converted image as a buffer suitable for storing in Oracle. The MIME
 * type returned is hard-coded to PNG.
 *
 * @param {Uint8Array} myImage the image to convert, provided as a buffer (BLOB)
 * @returns {Uint8Array} the converted image suitable for storing in a database
 */
export async function image2Greyscale(myImage) {
	let image;

	if (!myImage) {
		throw new Error("you did not provide a valid image to the function");
	}

	// try to parse/open the image for use with JIMP. This is slow.
	try {
		image = await Jimp.read(myImage);
	} catch (err) {
		throw new Error(`failed to open image the image: ${err}`);
	}

	// convert the colour image to greyscale and return the result as a
	// UInt8Array, suitable for storing in the database
	image.greyscale();

	// return the result as a PNG
	// TODO: read the MIME type from the image and set it accordingly
	return image.getBuffer("image/png");
}
