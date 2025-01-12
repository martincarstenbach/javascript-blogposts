import dotenv from "dotenv";
dotenv.config();

const config = {
	user: process.env.DB_USERNAME,
	password: process.env.DB_PASSWORD,
	connectString: process.env.DB_CONN_STRING,
};

export { config };
