import oracledb from "oracledb";
import { config as dbConfig } from "./config.mjs";

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
oracledb.autoCommit = true;

class DBConnector {
	constructor() {
		this.pool = null;
	}

	async createPool() {
		if (!this.pool) {
			try {
				this.pool = await oracledb.createPool({
					...dbConfig,
					poolMax: 10,
					poolMin: 10,
				});
				console.log("Connection pool created successfully.");
			} catch (error) {
				console.error("Error creating connection pool:", error);
				throw error;
			}
		}
	}

	async getConnection(options = {}) {
		await this.createPool();
		try {
			const connection = await this.pool.getConnection({
				...dbConfig,
				...options,
			});
			return connection;
		} catch (error) {
			console.error("Error getting connection:", error);
			throw error;
		}
	}
}

const dbConnector = new DBConnector();

export { dbConnector };
