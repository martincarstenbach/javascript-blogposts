import mocha from "mocha";
import { assert } from "chai";

let lastMessageId;

describe("All Unit Tests", () => {
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
		it("should retrieve one or more messages from the database", async () => {
			const response = await fetch("http://localhost:3000/api/messages");

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();
			assert.isAtLeast(data.length, 1, "not a single message found");
		});
	});
	describe("Retrieval of a single messages", () => {
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
	});
	describe("Deleting messages", () => {
		it("should delete the first message", async () => {
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
				"failed to delete the first message",
			);
		});
	});
});
