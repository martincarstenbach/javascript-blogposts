set serveroutput on

begin
    test_process_order;
end;
/

select
    *
from
    orders;

rollback;