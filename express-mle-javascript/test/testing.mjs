import mocha from "mocha";
import { assert } from "chai";

let lastMessageId;

describe("All Unit Tests", () => {
	/**
	 * SESSION INFO
	 */
	describe("Session Info tests", () => {
		it("should print session info", async () => {
			const response = await fetch("http://localhost:3000/api/info");

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();
			assert.deepEqual(
				data,
				{ username: "APP_USER", release: "23.6.0.24.10" },
				"you should be connect as APP_USER to a 23.6 database",
			);
		});
	});

	describe("Posting a message", () => {
		/**
		 * SUCCESSFUL POST
		 */
		it("should post a message to the database successfully", async () => {
			const response = await fetch("http://localhost:3000/api/messages", {
				method: "POST",
				body: JSON.stringify({ message: "posted via mocha" }),
				headers: {
					"Content-Type": "application/json",
				},
			});

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();

			lastMessageId = data.messageId;

			assert.equal(
				data.status,
				"success",
				"unknown error when inserting a message into the database",
			);
		});

		/**
		 * POST FAILS due to invalid content
		 */
		it("should fail posting a message to the database", async () => {
			const response = await fetch("http://localhost:3000/api/messages", {
				method: "POST",
				body: JSON.stringify({ foo: "bar" }),
				headers: {
					"Content-Type": "application/json",
				},
			});

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();
			assert.equal(
				data.status,
				"error",
				"the insert didn't generate an error although it should have",
			);
		});
	});

	describe("Retrieval of all messages", () => {
		/**
		 * RETRIEVE ALL MESSAGES
		 */
		it("should retrieve one or more messages from the database", async () => {
			const response = await fetch("http://localhost:3000/api/messages");

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();
			assert.isAtLeast(data.length, 1, "not a single message found");
		});
	});

	describe("Retrieval of a single message", () => {
		/**
		 * RETRIEVE A SINGLE MESSAGE
		 */
		it("should retrieve the last message posted from the database", async () => {
			const response = await fetch(
				`http://localhost:3000/api/messages/${lastMessageId}`,
			);

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();
			assert.isAtLeast(data.length, 1, "not a single message found");
		});

		/**
		 * FAIL TO RETRIEVE A MESSAGE due to an invalid value
		 */
		it("should fail to retrieve a message due to an invalid parameter type", async () => {
			const response = await fetch(
				"http://localhost:3000/api/messages/notANumber",
			);

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();
			assert.equal(
				data.status,
				"error",
				"somehow the database managed to convert a string to a number that cannot be converted",
			);
		});

		/**
		 * FAIL TO RETRIEVE A MESSAGE because it does not exist
		 */
		it("should fail to retrieve a message due to a negative ID", async () => {
			const response = await fetch("http://localhost:3000/api/messages/-1");

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();
			assert.equal(
				data.length,
				0,
				"somehow the database managed to fetch message with ID -1 which should be impossible",
			);
		});
	});

	describe("Deleting messages", () => {
		/**
		 * DELETE A MESSAGE
		 */
		it("should delete the last message inserted", async () => {
			const response = await fetch(
				`http://localhost:3000/api/messages/${lastMessageId}`,
				{
					method: "DELETE",
				},
			);

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();
			assert.equal(
				data.status,
				"success",
				`somehow the database failed to delete message ${lastMessageId}`,
			);
		});

		/**
		 * FAIL TO DELETE A MESSAGE due to an invalid ID
		 */
		it("should fail to delete a message due to an invalid parameter type", async () => {
			const response = await fetch(
				"http://localhost:3000/api/messages/notANumber",
				{
					method: "DELETE",
				},
			);

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();
			assert.equal(
				data.status,
				"error",
				"somehow the database managed to delete a message that has 'notANumber' as its pk",
			);
		});

		/**
		 * FAIL TO DELETE A MESSAGE due to a non-existing ID
		 */
		it("should fail to delete a message due to a negative ID", async () => {
			const response = await fetch("http://localhost:3000/api/messages/-1", {
				method: "DELETE",
			});

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();
			assert.equal(
				data.status,
				"error",
				"somehow the database managed to delete a message that has 'notANumber' as its pk",
			);
		});
	});
});
