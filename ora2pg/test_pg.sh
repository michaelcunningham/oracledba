echo
echo "Testing a connection to PostgreSQL using \"psql\""
echo

psql -U postgres -h 192.168.56.107 << EOF
\l
\q
EOF
