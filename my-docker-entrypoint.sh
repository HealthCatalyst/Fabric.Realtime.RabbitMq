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

# if $HOME is different than copy files from /var/lib/rabbitmq to $HOME
# if [[ "$RABBITMQ_STORE" == "/var/lib/rabbitmq" ]]; then
# 	echo "HOME environment variable was not changed so no copying needed"
# else
# 	if [[ ! -d "$RABBITMQ_STORE/mnesia" ]]; then
# 		 echo "copying all files from /var/lib/rabbitmq to $RABBITMQ_STORE"
# 		/etc/init.d/rabbitmq-server stop || echo ""
# 		rabbitmqctl stop_app \
# 			&& rabbitmqctl reset
# 		mkdir -p "$RABBITMQ_STORE/mnesia"
# 		cp --verbose -r -n "/var/lib/rabbitmq/mnesia/" "$RABBITMQ_STORE/mnesia"
# 		export RABBITMQ_MNESIA_BASE="$RABBITMQ_STORE/mnesia"
# 		rabbitmqctl stop_app \
# 			&& rabbitmqctl join_cluster \
# 			&& rabbitmqctl start_app
# 	else
# 		echo "$HOME/mnesia already exists so we're not copying files to it"
# 	fi
# fi

chown -R rabbitmq:rabbitmq "$RABBITMQ_MNESIA_BASE"

sh "./setupusers.sh"

exec /usr/local/bin/docker-entrypoint.sh rabbitmq-server