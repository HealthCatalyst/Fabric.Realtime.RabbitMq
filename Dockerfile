FROM rabbitmq:3-management

RUN apt-get update \
    && apt-get install openssl \
    && mkdir -p /opt/healthcatalyst/testca \
    && apt-get install tofrodos \
    && ln -s /usr/bin/fromdos /usr/bin/dos2unix \
	&& mkdir -p /opt/healthcatalyst/testca/certs \
	&& mkdir -p /opt/healthcatalyst/testca/private \
	&& chmod 700 /opt/healthcatalyst/testca/private \
	&& echo 01 > /opt/healthcatalyst/testca/serial \
	&& touch /opt/healthcatalyst/testca/index.txt

# update erlang
RUN apt-get install -y wget \
    && echo 'deb http://packages.erlang-solutions.com/debian stretch contrib' | tee /etc/apt/sources.list.d/erlang.list \
    && wget https://packages.erlang-solutions.com/debian/erlang_solutions.asc \
    && apt-key add erlang_solutions.asc \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
		erlang-asn1 \
		erlang-crypto \
		erlang-eldap \
		erlang-inets \
		erlang-mnesia \
		erlang-nox \
		erlang-os-mon \
		erlang-public-key \
		erlang-ssl \
		erlang-xmerl

# COPY openssl.cnf /opt/healthcatalyst/testca

COPY rabbitmq.config /etc/rabbitmq/rabbitmq.config

COPY scripts /opt/healthcatalyst/ 

ADD docker-entrypoint.sh ./docker-entrypoint.sh

RUN mkdir -p /opt/healthcatalyst/server \
	&& mkdir -p /opt/healthcatalyst/client \
	&&  dos2unix /opt/healthcatalyst/setupca.sh \
    && chmod +x /opt/healthcatalyst/setupca.sh \
    && dos2unix /opt/healthcatalyst/generateservercert.sh \
    && chmod +x /opt/healthcatalyst/generateservercert.sh \
	&& dos2unix /opt/healthcatalyst/generateclientcert.sh \
	&& chmod +x /opt/healthcatalyst/generateclientcert.sh \
	&& dos2unix /opt/healthcatalyst/generatecerts.sh \
	&& chmod +x /opt/healthcatalyst/generatecerts.sh \
	&& dos2unix ./docker-entrypoint.sh \
	&& chmod +x ./docker-entrypoint.sh

COPY openssl.cnf /opt/healthcatalyst/testca

ENTRYPOINT [ "./docker-entrypoint.sh" ]