#!/bin/bash

set -eu


CMD /bin/bash /home/setupca.sh \
	&& /bin/bash /home/generateservercert.sh Imran \
	&& /etc/init.d/rabbitmq-server restart \
	&& /bin/bash /home/generateclientcert.sh Imran \
	&& rabbitmq-server