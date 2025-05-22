/**
 * Polyfills for node's timer API.
 *
 * WARNING
 *
 * Most JavaScript runtimes typically have 2 separate task queues. The _microtask_
 * queue is used to execute promise reactions. There's another one, referred to as
 * the _task queue_ that's mostly used for I/O related work. Timers are usually
 * part of the task queue, meaning that if you schedule a task it will run _after_
 * all scheduled micro tasks.
 *
 * The polyfill introduced here does not behave that way which may break some
 * packages that rely on this principle for event dispatching.
 */

function queueMicrotask(fun) {
	Promise.resolve().then(fun);
}

let timerID = 0;

const canceledTimers = new Set();

const existingTimers = new Set();

export function setTimeout(cb, time, ...args) {
	const getTime = () =>
		session.execute(
			`
    declare
        now timestamp;
    begin
        now := current_timestamp;
        :0 := (
            extract(day from now) * 86400 +
            extract(hour from now) * 3600 +
            extract(minute from now) * 60 +
            extract(second from now)
            ) * 1000;
    end;`,
			[{ dir: oracledb.BIND_OUT, type: oracledb.NUMBER }],
		).outBinds[0];

	const timeToTrigger = getTime() + time;

	const myID = timerID++;

	const checkerFunction = () => {
		if (canceledTimers.has(myID)) {
			canceledTimers.delete(myID);

			existingTimers.delete(myID);

			return;
		}

		const now = getTime();

		if (now >= timeToTrigger) {
			existingTimers.delete(myID);

			cb.apply(null, args);
		} else {
			queueMicrotask(checkerFunction);
		}
	};

	queueMicrotask(checkerFunction);

	existingTimers.add(myID);

	return myID;
}

export function clearTimeout(jobID) {
	if (existingTimers.has(jobID)) {
		canceledTimers.add(jobID);
	}
}

let intervalIDCounter = 0;

const existingIntervals = new Set();

const cancelledIntervals = new Set();

export function setInterval(cb, time, ...args) {
	const getTime = () =>
		session.execute(
			`
        declare
            now timestamp;
        begin
            now := current_timestamp;
            :0 := (
                extract(day from now) * 86400 +
                extract(hour from now) * 3600 +
                extract(minute from now) * 60 +
                extract(second from now)
                ) * 1000;
        end;`,
			[{ dir: oracledb.BIND_OUT, type: oracledb.NUMBER }],
		).outBinds[0];

	let timeToTrigger = getTime() + time;

	const myID = intervalIDCounter++;

	const checkerFunction = () => {
		if (cancelledIntervals.has(myID)) {
			canceledTimers.delete(myID);

			existingIntervals.delete(myID);

			return;
		}

		const now = getTime();

		if (now >= timeToTrigger) {
			timeToTrigger = now + time;

			cb.apply(null, args);
		}

		queueMicrotask(checkerFunction);
	};

	queueMicrotask(checkerFunction);

	existingIntervals.add(myID);

	return myID;
}

export function clearInterval(intervalID) {
	if (existingIntervals.has(intervalID)) {
		cancelledIntervals.add(intervalID);
	}
}
// add your code here
