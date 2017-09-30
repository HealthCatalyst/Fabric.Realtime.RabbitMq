
echo "Generating certificates for hostname:["$1"]"

/opt/healthcatalyst/scripts/setupca.sh $1
/opt/healthcatalyst/scripts/generateservercert.sh $1
/opt/healthcatalyst/scripts/generateclientcert.sh $1
