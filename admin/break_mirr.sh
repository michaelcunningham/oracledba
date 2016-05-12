tdcdv4
export source_filer=na108-10g
export target_filer=na109-10g
export SOURCE_SID=tdcprd
export snapshot_name=post_cycle.1

export source_clone=${SOURCE_SID}_${ORACLE_SID}_clone
export source_arch_clone=${SOURCE_SID}arch_${ORACLE_SID}arch_clone

rsh ${target_filer} snapmirror quiesce ${ORACLE_SID}
rsh ${target_filer} snapmirror break ${ORACLE_SID}
rsh ${target_filer} vol options ${ORACLE_SID} fs_size_fixed off
rsh ${target_filer} snap delete -a -f ${ORACLE_SID}

mount /${ORACLE_SID}
mount /${ORACLE_SID}arch

rsh ${source_filer} snapmirror release ${source_clone} ${target_filer}:${ORACLE_SID}
rsh ${target_filer} snapmirror release ${ORACLE_SID} ${target_filer}:${ORACLE_SID}

rsh ${source_filer} snapmirror release ${source_arch_clone} ${target_filer}:${ORACLE_SID}arch
rsh ${target_filer} snapmirror release ${ORACLE_SID}arch ${target_filer}:${ORACLE_SID}arch

rsh ${source_filer} vol offline ${source_clone}
rsh ${source_filer} vol destroy ${source_clone} -f
rsh ${source_filer} vol offline ${source_arch_clone}
rsh ${source_filer} vol destroy ${source_arch_clone} -f

rm $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora

/dba/admin/mk_control_file_from_master.sh ${SOURCE_SID} ${ORACLE_SID}

sqlplus /nolog << EOF
connect / as sysdba
set linesize 120
create spfile from pfile;
@/dba/admin/ctl/${ORACLE_SID}_control.sql
exit;
EOF

find /${ORACLE_SID}arch/arch -name "*.dbf" -exec rm {} \;
sleep 10
rsh $target_filer vol size ${ORACLE_SID}arch 2g
rsh $target_filer snap reserve ${ORACLE_SID}arch 0

rsh $target_filer snap reserve ${ORACLE_SID} 0
/dba/admin/shrink_data_vol.sh ${ORACLE_SID} 0.8

adhoc
./post_restore.sh

/dba/admin/start_listener.sh $ORACLE_SID

/dba/admin/log_db_refresh_info.sh $ORACLE_SID $SOURCE_SID $snapshot_name

