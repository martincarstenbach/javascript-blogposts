# Polyfills for Multilingual Engine/JavaScript

As per its [documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/introduction-to-mle.html), Multilingual Engine/JavaScript started as a pure ECMAScript implementation. The [timeout and interval](https://nodejs.org/docs/latest-v20.x/api/timers.html#settimeoutcallback-delay-args) API is node specific, in other words, not part of the standard. Although more and more web APIs are added to MLE/JavaScript over the past few Release Updates timeouts and intervals aren't present in Oracle Database 23ai Release Update 8. Until they are, a little extra work is necessary: you have to write a polyfill.

This little project demonstrates the creation and use of polyfills for `setTimeout()`, `clearTimeout()`, `setInterval()`, and `clearInterval()`. This is not a perfect solution though!

Most JavaScript runtimes typically have 2 separate task queues. The _microtask_ queue is used to execute promise reactions. There's another one, referred to as the _task queue_ that's mostly used for I/O related work. Timers are usually part of the task queue, meaning that if you schedule a task it will run _after_ all scheduled micro tasks. The polyfill introduced in this article does not behave that way which may break some packages that rely on this principle for event dispatching.

Please refer to the blog post for more details.