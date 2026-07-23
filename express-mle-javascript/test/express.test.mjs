import { describe, it, expect } from "vitest";

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
			expect(data).toEqual({
				username: "DEMOUSER",
				release: "23.26.2.0.0",
			});
		});
	});

	describe("Posting a message", () => {
		/**
		 * SUCCESSFUL POST
		 */
		it("should post a message to the database successfully", async () => {
			const response = await fetch("http://localhost:3000/api/messages", {
				method: "POST",
				body: JSON.stringify({ message: "posted via vitest" }),
				headers: {
					"Content-Type": "application/json",
				},
			});

			if (!response.ok) {
				throw new Error(`Fetch error; response status: ${response.status}`);
			}

			const data = await response.json();
			lastMessageId = data.messageId;

			expect(data.status).toBe("success");
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
			expect(data.status).toBe("error");
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
			expect(data.length).toBeGreaterThanOrEqual(1);
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
			expect(data.length).toBeGreaterThanOrEqual(1);
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
			expect(data.status).toBe("error");
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
			expect(data.length).toBe(0);
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
			expect(data.status).toBe("success");
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
			expect(data.status).toBe("error");
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
			expect(data.status).toBe("error");
		});
	});
});
