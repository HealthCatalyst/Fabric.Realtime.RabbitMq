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
		&& /bin/bash /opt/healthcatalyst/generateservercert.sh \
		&& /etc/init.d/rabbitmq-server restart \
		&& /bin/bash /opt/healthcatalyst/generateclientcert.sh \
		&& /etc/init.d/rabbitmq-server stop
else
	echo "certificates already exist so we're not regenerating them"
fi

# passwords don't have to be secure since only servers in the docker swarm cluster can
#  access with plain username/password (we don't open the non-SSL port, 5672, outside the swarm)
# All access from outside the swarm happens on port 5671 with SSL where we pick the username from the client cert
/etc/init.d/rabbitmq-server restart \
	&& echo "enabling ssl auth plugin" \
	&& rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl \
	&& echo "creating fabricrabbitmquser user" \
	&& rabbitmqctl add_user fabricrabbitmquser test \
	&& rabbitmqctl set_user_tags fabricrabbitmquser administrator \
	&& rabbitmqctl set_permissions -p / fabricrabbitmquser ".*" ".*" ".*" \
	&& echo "creating fabricinterfaceengine user" \
	&& rabbitmqctl add_user fabricinterfaceengine mypassword \
	&& rabbitmqctl set_user_tags fabricinterfaceengine ip-private \
	&& rabbitmqctl set_permissions -p / fabricinterfaceengine ".*" ".*" ".*" \
	&& /etc/init.d/rabbitmq-server stop

exec rabbitmq-server