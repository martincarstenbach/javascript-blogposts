--liquibase formatted sql
--changeset queryparams:02

insert into staff (id,name) values ('1','avery johnson');
insert into staff (id,name) values ('2','blake ramirez');
insert into staff (id,name) values ('3','casey nguyen');
insert into staff (id,name) values ('4','devon patel');
insert into staff (id,name) values ('5','elliott brooks');
insert into staff (id,name) values ('6','finley chen');
insert into staff (id,name) values ('7','harper castillo');
insert into staff (id,name) values ('8','jordan kim');
insert into staff (id,name) values ('9','parker singh');
insert into staff (id,name) values ('10','riley thompson');

insert into action_items (id,name,status) values ('2','conduct q1 customer feedback interviews','OPEN');
insert into action_items (id,name,status) values ('3','roll out workflow automation pilot','OPEN');
insert into action_items (id,name,status) values ('4','publish ai governance guidelines','COMPLETE');

insert into action_item_team_members (id,action_id,user_id,role) values ('5','2','1','LEAD');
insert into action_item_team_members (id,action_id,user_id,role) values ('6','2','5','MEMBER');
insert into action_item_team_members (id,action_id,user_id,role) values ('7','3','4','LEAD');
insert into action_item_team_members (id,action_id,user_id,role) values ('8','3','6','MEMBER');
insert into action_item_team_members (id,action_id,user_id,role) values ('9','4','8','LEAD');
insert into action_item_team_members (id,action_id,user_id,role) values ('10','4','9','MEMBER');

commit;