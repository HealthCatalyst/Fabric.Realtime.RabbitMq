FROM rabbitmq:3-management

RUN apt-get update \
    && apt-get install openssl \
    && mkdir -p /opt/healthcatalyst/testca \
    && apt-get install tofrodos \
    && ln -s /usr/bin/fromdos /usr/bin/dos2unix \
	&& mkdir -p /home/testca/certs \
	&& mkdir -p /home/testca/private \
	&& chmod 700 /home/testca/private \
	&& echo 01 > /home/testca/serial \
	&& touch /home/testca/index.txt

# update erlang
# RUN apt-get install -y wget \
#     && echo 'deb http://packages.erlang-solutions.com/debian stretch contrib' | tee /etc/apt/sources.list.d/erlang.list \
#     && wget https://packages.erlang-solutions.com/debian/erlang_solutions.asc \
#     && apt-key add erlang_solutions.asc \
#     && apt-get update \
#     && apt-get install -y --no-install-recommends \
# 		erlang-asn1 \
# 		erlang-crypto \
# 		erlang-eldap \
# 		erlang-inets \
# 		erlang-mnesia \
# 		erlang-nox \
# 		erlang-os-mon \
# 		erlang-public-key \
# 		erlang-ssl \
# 		erlang-xmerl

# COPY openssl.cnf /opt/healthcatalyst/testca

COPY rabbitmq.config /etc/rabbitmq/rabbitmq.config

COPY scripts /opt/healthcatalyst/scripts 

# RUN dos2unix /opt/healthcatalyst/scripts/setupca.sh \
#     && chmod +x /opt/healthcatalyst/scripts/setupca.sh \
#     && dos2unix /opt/healthcatalyst/scripts/generateservercert.sh \
#     && chmod +x /opt/healthcatalyst/scripts/generateservercert.sh \
# 	&& dos2unix /opt/healthcatalyst/scripts/generateclientcert.sh \
# 	&& chmod +x /opt/healthcatalyst/scripts/generateclientcert.sh \
# 	&& dos2unix /opt/healthcatalyst/scripts/generatecerts.sh \
# 	&& chmod +x /opt/healthcatalyst/scripts/generatecerts.sh

# CMD /bin/bash /opt/healthcatalyst/scripts/setupca.sh \
# 	&& /bin/bash /opt/healthcatalyst/scripts/generateservercert.sh Imran \
# 	&& /etc/init.d/rabbitmq-server restart \
# 	&& /bin/bash /opt/healthcatalyst/scripts/generateclientcert.sh Imran \
# 	&& /etc/init.d/rabbitmq-server restart

COPY openssl.cnf /home/testca
COPY prepare-server.sh generate-client-keys.sh /home/

RUN mkdir -p /home/server \
	&& mkdir -p /home/client \
	&& dos2unix /home/prepare-server.sh \
	&& dos2unix /home/generate-client-keys.sh \
	&& chmod +x /home/prepare-server.sh /home/generate-client-keys.sh

RUN /bin/bash /home/prepare-server.sh \
	&& /etc/init.d/rabbitmq-server restart

CMD /bin/bash /home/generate-client-keys.sh && rabbitmq-server
#sleep infinity