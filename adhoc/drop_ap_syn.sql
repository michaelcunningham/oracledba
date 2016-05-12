set heading off
spool drop_all_ap_syn.sql
select 'drop synonym '||synonym_name||';'  from user_synonyms where TABLE_OWNER = 'AP_WYNSURE'
 or TABLE_OWNER = 'AP_ODS_POLICY'
 or TABLE_OWNER = 'AP_DW_V2'
 or TABLE_OWNER = 'AP_EDW_DATAMART'
 or TABLE_OWNER = 'AP_AS400'
 or TABLE_OWNER = 'AP_NOVA_INT'
/
spool off 
@drop_all_ap_syn.sql
rm drop_all_ap_syn.sql
exit
