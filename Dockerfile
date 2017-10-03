FROM rabbitmq:3-management

RUN apt-get update \
    && apt-get install openssl \
    && mkdir -p /opt/healthcatalyst/testca \
    && apt-get install tofrodos \
    && ln -s /usr/bin/fromdos /usr/bin/dos2unix

# update erlang
RUN apt-get install wget \
    && echo 'deb http://packages.erlang-solutions.com/debian stretch contrib' | tee /etc/apt/sources.list.d/erlang.list \
    && wget https://packages.erlang-solutions.com/debian/erlang_solutions.asc \
    && apt-key add erlang_solutions.asc \
    && agt-get update; \
    && 	apt-get install -y --no-install-recommends \
		erlang-asn1 \
		erlang-crypto \
		erlang-eldap \
		erlang-inets \
		erlang-mnesia \
		erlang-nox \
		erlang-os-mon \
		erlang-public-key \
		erlang-ssl \
		erlang-xmerl; 

COPY openssl.cnf /opt/healthcatalyst/testca

COPY rabbitmq.config /etc/rabbitmq/rabbitmq.config

COPY scripts /opt/healthcatalyst/scripts 

RUN dos2unix /opt/healthcatalyst/scripts/setupca.sh \
    && chmod +x /opt/healthcatalyst/scripts/setupca.sh \
    && dos2unix /opt/healthcatalyst/scripts/generateservercert.sh \
    && chmod +x /opt/healthcatalyst/scripts/generateservercert.sh \
	&& dos2unix /opt/healthcatalyst/scripts/generateclientcert.sh \
	&& chmod +x /opt/healthcatalyst/scripts/generateclientcert.sh \
	&& dos2unix /opt/healthcatalyst/scripts/generatecerts.sh \
	&& chmod +x /opt/healthcatalyst/scripts/generatecerts.sh

