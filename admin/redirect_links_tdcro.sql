drop public database link tdcro_nova;
drop public database link tdcro_star;
drop public database link tdcro_vista;
create public database link tdcro_nova connect to nova_select identified by nova_select using 'tdcro';
create public database link tdcro_vista connect to vistaprd identified by tdcro using 'tdcro';
create public database link tdcro_star connect to dblink_user identified by tdcro using 'tdcro';
