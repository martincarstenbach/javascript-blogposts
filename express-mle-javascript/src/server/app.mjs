import express from "express";
import bodyParser from "body-parser";
import oracledb from "oracledb";

import { dbConnector as db } from "./utils/connection.mjs";

// define some useful defaults for this application
oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
oracledb.autoCommit = true;

const app = express();
app.use(bodyParser.json());

const port = 3000;
const prefix = "/api/messages";

/**
 * Get database session info
 */
app.get("/api/info", async (_req, res, next) => {
	try {
		const connection = await db.getConnection();

		const result = await connection.execute("select get_db_details as details");

		res.send(result.rows[0].DETAILS);
	} catch (error) {
		next(error);
	}
});

/**
 * Get all messages
 */
app.get(`${prefix}`, async (_req, res, next) => {
	try {
		const connection = await db.getConnection();

		const result = await connection.execute("select get_messages as data");

		res.send(result.rows[0].DATA);
	} catch (error) {
		next(error);
	}
});

/**
 * Get a specific message
 */
app.get(`${prefix}/:id`, async (req, res, next) => {
	const id = req.params.id;

	// cannot perform a lookup on anything other than the PK
	// the PK column is numeric, hence this code must ensure
	// a numeric value is passed
	// biome-ignore lint/suspicious/noGlobalIsNan: coercion to number is acceptable
	if (isNaN(id)) {
		res.send({
			status: "error",
			details: "please provide a valid number",
		});
		return;
	}

	try {
		const connection = await db.getConnection();

		const result = await connection.execute(
			"select get_message_by_id(:id) as data",
			[id],
		);

		res.send(result.rows[0].DATA);
	} catch (error) {
		next(error);
	}
});

/**
 * Pass the entire request body to MLE/JavaScript
 */
app.post(`${prefix}`, async (req, res, next) => {
	const message = req.body.message;
	if (message === undefined || message.length === 0) {
		res.send({
			status: "error",
			details: "please provide a valid mesage-see readme for details",
		});
		return;
	}

	try {
		const connection = await db.getConnection();

		await connection.execute("begin process_data(:message); end;", [message]);

		res.send({
			status: "success",
			details: "message successfully inserted",
		});
	} catch (error) {
		next(error);
	}
});

/**
 * start processing and listen for requests
 */
app.listen(port, () => {
	console.log(`app listening on port ${port}`);
});
