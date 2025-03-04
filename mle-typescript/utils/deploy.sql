
-- This SQL script assumes you use SQL Developer Command Line (SQLcl) for the deployment
-- SQLcl has built-in support for connection management. It is assumed that you created
-- the database using ../../database/compose*.yml, which automatically creates a demouser
-- account for you. If you haven't, create a stored connection in SQLcl like so:
-- SQL> connect -replace -savepwd -save demouser demouser/demouser@localhost/freepdb1
-- from that point on you can use this named connection as demonstrated by this script.
-- 
-- DO NOT USE THIS FOR A PRODUCTION SETUP
--

conn -n demouser

whenever sqlerror exit 127

-- stage 1: deploy database code
cd src/database
lb update -changelog-file controller.xml

-- stage 2: deploy MLE code
cd ../javascript
mle create-module -filename todos.js -module-name todos_module -replace

create or replace mle env todos_env imports (
    'todos' module todos_module
);

exit
