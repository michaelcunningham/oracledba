if [ $# -ne 1 ]
then
   echo " "
   echo "Usage is : $0 <Database name>"
   echo "Example : $0 PDB01"
   echo " "
   exit 1
fi

 tnsping $1 | grep HOST | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-BBEEE`9]?)'

