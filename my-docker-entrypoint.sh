#!/bin/bash

set -eu

echo "running docker-entrypoint.sh"

if [[ ! -z "${CERT_HOSTNAME_FILE:-}" ]]
then
	echo "CERT_HOSTNAME_FILE is set so reading from $CERT_HOSTNAME_FILE"
	CERT_HOSTNAME=$(cat $CERT_HOSTNAME_FILE)
fi

CertHostName="${CERT_HOSTNAME:-}"
if [[ ! -z "${DISABLE_SSL:-}" ]]
then
	# use insecure setting
	echo "WARNING:  DISABLE_SSL specified so running in insecure mode"
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

echo "rabbitmq user id:"
id -u rabbitmq

if [[ ! -z "${RABBITMQ_MNESIA_BASE:-}" ]]
then
	echo "setting ownership on $RABBITMQ_MNESIA_BASE"
	chown --verbose -R rabbitmq:rabbitmq "$RABBITMQ_MNESIA_BASE"
fi

./setupusers.sh

exec /usr/local/bin/docker-entrypoint.sh rabbitmq-server