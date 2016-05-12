#!/bin/sh

exp novaprd/ojmt33@starprd file=/dba/export/dmp/exp_case_sensitive_nova_tables.dmp \
log=/dba/export/log/exp_case_sensitive_nova_tables.log statistics=none \
tables='Agency',"Agency Business Information","Agency Groups","Agency Types","Agent Business Information","tblSubmissionData1","Agent"

