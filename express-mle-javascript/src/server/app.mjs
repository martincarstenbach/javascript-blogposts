import express from "express";
import bodyParser from "body-parser";
import oracledb from "oracledb";

import { dbConnector as db } from "./utils/connection.mjs";

const app = express();
app.use(bodyParser.json());

const port = 3000;

/**
 * Get database info
 */
app.get("/info", async (_req, res) => {
	const connection = await db.getConnection();

	const result = await connection.execute("select get_db_details as details");

	res.send(result.rows[0].DETAILS);
});

/**
 * Get a specific message
 */
app.get("/:id", async (req, res) => {
	const connection = await db.getConnection();

	const id = req.params.id;

	const result = await connection.execute("select get_message_by_id(:id) as data", [id]);

	res.send(result.rows[0].DATA);
});

/**
 * Pass the entire request body to MLE/JavaScript
 * Invoke as follows:
 *
 * curl -X POST -H "Content-Type: application/json" -d '{"message": "this message has been provided via curl"}' http://localhost:3000
 */
app.post("/", async (req, res) => {
	const payload = req.body;
	if (payload === undefined) {
		res.send({
			status: "error",
			details: "please provide a payload",
		});
	}

	const connection = await db.getConnection();

	try {
		await connection.execute("begin process_data(:data); end;", {
			data: {
				dir: oracledb.BIND_IN,
				val: payload,
				type: oracledb.DB_TYPE_JSON,
			},
		});

		res.send({
			status: "success",
			details: "message successfully inserted",
		});
	} catch (err) {
		res.send({
			status: "error",
			details: `the following error occurred: ${err}`,
		});
	}
});

/**
 * start processing and listen for requests
 */
app.listen(port, () => {
	console.log(`app listening on port ${port}`);
});
