#!/bin/bash

set -eu

echo "running setup.sh"


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
	&& ([[ ! -z "${DISABLE_SSL:-}" ]] || echo "deleting guest user") \
	&& ([[ ! -z "${DISABLE_SSL:-}" ]] || rabbitmqctl delete_user guest) \
	&& /etc/init.d/rabbitmq-server stop


echo "Rabbitmq logs"
ls -al /var/log/rabbitmq
cat /var/log/rabbitmq/startup_err
cat /var/log/rabbitmq/startup_log


# exec rabbitmq-server
# echo "$@"
# exec /usr/local/bin/docker-entrypoint.sh "$@"