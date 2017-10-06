#!/bin/bash

set -eu


/bin/bash /home/setupca.sh \
	&& /bin/bash /home/generateservercert.sh Imran \
	&& /etc/init.d/rabbitmq-server restart
    
sleep 10s;

/bin/bash /home/generateclientcert.sh Imran 

exec rabbitmq-server