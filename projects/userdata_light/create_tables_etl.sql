--drop table userdata_master purge;

--drop table address_master purge;

--drop table user_auth_master purge;

--drop table user_email_master purge;

--drop table userdata_extended_master purge;

--drop table user_bouncelist_master purge;

--drop table userdata_light_control purge;

--drop table userdata_light_history purge;

-- drop table userdata_light_tmp purge;

create table userdata_light
(
        user_id                   number(15) not null,
        fictitious_user_id        raw(8),
        cancel_reason_code        number(2),
        gender                    char(1),
        birthdate                 date,
        locale                    varchar2(6),
        apps_optout_settings_1    number(20),
        date_registered           date,
        date_cancelled            date,
        date_validated            date,
        email                     varchar2(256),
        email_blocked             char(1),
        cc_iso                    varchar2(4),
        potential_fict_user_id    varchar2(15),
        last_login_date           date,
        ip_address                varchar2(15),
        state                     varchar2(3),
        zipcode                   varchar2(5),
        zipcode_ext               varchar2(4),
        date_boxed                date,
        boxed_reason              varchar2(100),
        reg_source                varchar2(3),
        ethnicity                 number(8),
        religion                  char(1),
        sexual_preference         char(1),
        type                      number(2),
        hi5_finished_wizard_date  date,
        primary_photo_id          number(15),
        photo_url                 varchar2(1024),
        dating                    char(1),
        friends                   char(1),
        serrelationship           char(1),
        networking                char(1),
        relationship              char(1),
        inferred_ethnicity        number(8),
        latitude                  number(12,7),
        longitude                 number(12,7),
        timezone_int_id           number(4),
        hide_online_status        char(1),
        search_prefs              varchar2(640),
        referrer_user_id          number(15),
        pets_search_prefs         varchar2(256),
        date_spammer_added        date,
        date_spammer_removed      date )
tablespace datatbs1;

create index userdata_light_ix1 on userdata_light( last_login_date )
tablespace datatbs1;



create table userdata_master(
	user_id				number(15) not null,
	fictitious_user_id		raw(8),
	cancel_reason_code		number(2),
	gender				char(1),
	birthdate			date,
	locale				varchar2(6),
	last_login_date			date,
	apps_optout_settings_1		number(20),
	reg_source			varchar2(3),
	ethnicity			number(8),
	religion			char(1),
	sexual_preference		char(1),
	type				number(2),
	hi5_finished_wizard_date	date,
	primary_photo_id		number(15),
	photo_url			varchar2(1024),
	dating				char(1),
	friends				char(1),
	serrelationship			char(1),
	networking			char(1),
	relationship			char(1),
	inferred_ethnicity		number(8),
	timezone_int_id			number(4),
	hide_online_status		char(1),
	search_prefs			varchar2(640) )
tablespace datatbs1;

create table address_master(
	user_id		number(15),
	cc_iso		varchar2(4),
	state		char(3),
	zipcode		varchar2(5),
	zipcode_ext	varchar2(4),
	latitude	number(12,7),
	longitude	number(12,7) )
tablespace datatbs1;

create table user_auth_master(
	user_id			number(15) not null,
	primary_email_id	number(15),
	date_registered		date,
	date_cancelled		date,
	date_validated		date,
	date_boxed		date,
	boxed_reason		varchar2(100),
	date_spammer_added	date,
	date_spammer_removed	date )
tablespace datatbs1;


create table user_email_master(
	user_id			number(15) not null,
	email_address_id	number(15),
	email			varchar2(256),
	email_blocked		char( 1 ) default 'N' not null )
tablespace datatbs1;

create table userdata_extended_master(
	user_id			number(15) not null,
	ip_address		varchar2(15),
	referrer_user_id	number(15),
	pets_search_prefs	varchar2(256) )
tablespace datatbs1;

create table userdata_light_control(
	control_id	integer not null,
	current_state	varchar2(15),
	status		varchar2(15),
	status_note	varchar2(500) )
tablespace datatbs1;

create unique index userdata_light_control_pk on userdata_light_control( control_id )
tablespace datatbs1;

alter table userdata_light_control add(
	constraint userdata_light_control_pk
	primary key( control_id )
	using index
	tablespace datatbs1 );

create table userdata_light_history(
	control_id			integer not null,
	begin_date			date not null,
	end_date			date,
	userdata_light_rows_prior	integer,
	userdata_light_rows_current	integer,
	part_1_begin_date		date,
	part_1_end_date			date,
	part_2_begin_date		date,
	part_2_end_date			date,
	part_3_begin_date		date,
	part_3_end_date			date )
tablespace datatbs1;

create unique index userdata_light_history_pk on userdata_light_history( control_id )
tablespace datatbs1;

alter table userdata_light_history add(
	constraint userdata_light_history_pk
	primary key( control_id )
	using index
	tablespace datatbs1 );

create table user_bouncelist_master(
	email	varchar2(256) )
tablespace datatbs1;
