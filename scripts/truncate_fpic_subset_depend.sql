truncate table OS_FORM;
truncate table OS_FORM_COPY_TYPE_MAP;
truncate table OS_FORM_DEVICE;
truncate table OS_FORM_DEVICE_ATTRB;
truncate table OS_FORM_DEVICE_ATTRB_GRP;
truncate table OS_FORM_DEVICE_MAP;
truncate table OS_FORM_MAP;
truncate table OS_FORM_SCHEDULE;
truncate table OS_FORM_RULE;
truncate table OS_FORM_RULE_CODE;
truncate table OS_FORM_COPY_TYPE;
truncate table OS_FORM_RULE_ATTRIBUTE;
truncate table OS_CRYSTAL_TRIGGER;
truncate table OS_FORM_DISTRIBUTION;
truncate table OS_FORM_DISTRIBUTION_ATTRB;
truncate table OS_FORM_REQUEST;
truncate table OS_FORM_VERSION;
truncate table OS_REQUEST_DETAIL;
truncate table OS_REQUEST_QUEUE;
truncate table OS_REQUEST_UTIL;
truncate table OS_TRANSACTION_TYPES;
truncate table PFUSER;
truncate table PFUSER_PROF;
truncate table CLAIMS_STAFF_AUTHORITY;
truncate table CLAIMS_STAFF_ROUTING;
truncate table FPIC_OS_FORM_EDITION_DATE;
truncate table CONFIG_EVENT_USER;
truncate table CONFIG_EVENT_UTIL;

@dischildfk SYSTEM_PARAMETER_UTIL
@dischildfk PFPROF
@dischildfk CLAIMS_STAFF
@dischildfk CONFIG_EVENT_HEADER
@dischildfk CONFIG_EVENT_DETAIL
@dischildfk CONFIG_EVENT_DETAIL_SQL

truncate table SYSTEM_PARAMETER_UTIL;
truncate table PFPROF;
truncate table CLAIMS_STAFF;
truncate table CONFIG_EVENT_HEADER;
truncate table CONFIG_EVENT_DETAIL;
truncate table CONFIG_EVENT_DETAIL_SQL;

@enchildfk SYSTEM_PARAMETER_UTIL
@enchildfk PFPROF
@enchildfk CLAIMS_STAFF
@enchildfk CONFIG_EVENT_HEADER
@enchildfk CONFIG_EVENT_DETAIL
@enchildfk CONFIG_EVENT_DETAIL_SQL

