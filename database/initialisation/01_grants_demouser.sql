alter session set container = freepdb1;

prompt JavaScript grants...
grant execute on javascript to demouser;
grant execute dynamic mle to demouser;

prompt role grants...
grant soda_app to demouser;
grant db_developer_role to demouser;

prompt default role all ...
alter user demouser default role all;

prompt quota ...
alter user demouser quota 100m on users;