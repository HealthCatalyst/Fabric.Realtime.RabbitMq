#!/bin/bash

set -eu

echo "running docker-entrypoint.sh"

CertHostName="${CERT_HOSTNAME:-}"
if [[ -z "$CertHostName" ]]
then
	# use insecure setting
	echo "WARNING: No CERT_HOSTNAME specified so running in insecure mode"
	cp /etc/rabbitmq/rabbitmq_nossl.config /etc/rabbitmq/rabbitmq.config
else
	echo "Setting up RabbitMq to use SSL"

	# wait for keys to become available
	while [[ ! -f "/opt/healthcatalyst/server/cert.pem" ]]
	do
		echo "waiting for /opt/healthcatalyst/testca/cacert.pem to become available"
		sleep 5s;
	done
	while [[ ! -f "/opt/healthcatalyst/testca/cacert.pem" ]]
	do
		echo "waiting for /opt/healthcatalyst/testca/cacert.pem to become available"
		sleep 5s;
	done
	while [[ ! -f "/opt/healthcatalyst/server/key.pem" ]]
	do
		echo "waiting for /opt/healthcatalyst/server/key.pem to become available"
		sleep 5s;
	done	

	if [[ ! -f "/opt/healthcatalyst/testca/cacert.pem" ]]
	then
		echo "ERROR: /opt/healthcatalyst/testca/cacert.pem was not found"
		exit 1
	fi
	if [[ ! -f "/opt/healthcatalyst/server/cert.pem" ]]
	then
		echo "ERROR: /opt/healthcatalyst/server/cert.pem was not found"
		exit 1
	fi
	if [[ ! -f "/opt/healthcatalyst/server/key.pem" ]]
	then
		echo "ERROR: /opt/healthcatalyst/server/key.pem was not found"
		exit 1
	fi

fi

rabbitMqMgmtUiPassword="${RABBITMQ_MGMT_UI_PASSWORD:-}"

rabbitMqMgmtUiPasswordFile=${RABBITMQ_MGMT_UI_PASSWORD_FILE:-}

if [[ ! -z "$rabbitMqMgmtUiPasswordFile" ]]
then
    echo "RABBITMQ_MGMT_UI_PASSWORD_FILE is set so reading from $rabbitMqMgmtUiPasswordFile"
    rabbitMqMgmtUiPassword=$(cat $rabbitMqMgmtUiPasswordFile)
fi

if [[ -z "$rabbitMqMgmtUiPassword" ]]
then
    echo "Either RABBITMQ_MGMT_UI_PASSWORD or RABBITMQ_MGMT_UI_PASSWORD_FILE must be set"
    exit 1
fi

# echo "setting mgmt ui password:"$rabbitMqMgmtUiPassword

# RABBITMQ_MNESIA_BASE=/opt/rabbitmq

# passwords don't have to be secure since only servers in the docker swarm cluster can
#  access with plain username/password (we don't open the non-SSL port, 5672, outside the swarm)
# All access from outside the swarm happens on port 5671 with SSL where we pick the username from the client cert

# copy from our location to the mounted volume
/etc/init.d/rabbitmq-server restart \
	&& echo "enabling ssl auth plugin" \
	&& rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl \
	&& echo "creating fabricrabbitmquser user" \
	&& rabbitmqctl add_user fabricrabbitmquser gryxA8wpqk8YU5hy \
	&& rabbitmqctl set_user_tags fabricrabbitmquser administrator \
	&& rabbitmqctl set_permissions -p / fabricrabbitmquser ".*" ".*" ".*" \
	&& echo "creating fabricinterfaceengine user" \
	&& rabbitmqctl add_user fabricinterfaceengine 3rzgUS7Enpj9qcG4 \
	&& rabbitmqctl set_user_tags fabricinterfaceengine ip-private \
	&& rabbitmqctl set_permissions -p / fabricinterfaceengine ".*" ".*" ".*" \
	&& echo "creating admin user" \
	&& rabbitmqctl add_user admin $rabbitMqMgmtUiPassword \
	&& rabbitmqctl set_user_tags admin administrator \
	&& rabbitmqctl set_permissions -p / admin ".*" ".*" ".*" \
	&& echo "deleting guest user" \
	&& rabbitmqctl delete_user guest \
	&& /etc/init.d/rabbitmq-server stop


exec rabbitmq-server