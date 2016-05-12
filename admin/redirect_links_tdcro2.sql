drop public database link tdcro_nova;
drop public database link tdcro_star;
drop public database link tdcro_vista;
create public database link tdcro_nova connect to nova_select identified by nova_select using 'tdcro2';
create public database link tdcro_vista connect to vistaprd identified by tdcro2 using 'tdcro2';
create public database link tdcro_star connect to dblink_user identified by tdcro2 using 'tdcro2';
