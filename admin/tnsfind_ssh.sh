if [ $# -ne 1 ]
then
   echo " "
   echo "Usage is : $0 <Database name>"
   echo "Example : $0 PDB01"
   echo " "
   exit 1
fi

echo " "
echo "###############################################################################"
echo " "
echo "Using information from ${ORACLE_HOME}/network/admin/tnsnames.ora"
echo " "
echo "###############################################################################"
echo " "
echo " "
export tns_server=$(/mnt/dba/admin/tnsfind.sh $1)
ssh -o UserKnownHostsFile=~/.ssh/known_hosts $tns_server;
#ssh $tns_server
