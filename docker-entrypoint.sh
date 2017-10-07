#!/bin/bash

set -eu

echo "running docker-entrypoint.sh"

echo "contents of /opt/healthcatalyst/client/"
echo "-------"
ls /opt/healthcatalyst/client/
echo "-------"

if [ ! -f "/opt/healthcatalyst/client/cert.pem" ]
then
	echo "no certificates found so regenerating them"
	/bin/bash /opt/healthcatalyst/setupca.sh \
		&& /bin/bash /opt/healthcatalyst/generateservercert.sh Imran \
		&& /etc/init.d/rabbitmq-server restart
		
	echo "enabling ssl auth plugin"
	rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl

	/bin/bash /opt/healthcatalyst/generateclientcert.sh Imran \
		&& /etc/init.d/rabbitmq-server stop
else
	echo "certificates already exist so we're not regenerating them"
fi

exec rabbitmq-server