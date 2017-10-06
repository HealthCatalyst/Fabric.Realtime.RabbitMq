#!/bin/bash

set -eu

/bin/bash /home/setupca.sh \
	&& /bin/bash /home/generateservercert.sh Imran \
	&& /etc/init.d/rabbitmq-server restart
    
/bin/bash /home/generateclientcert.sh Imran \
	&& /etc/init.d/rabbitmq-server stop

exec rabbitmq-server