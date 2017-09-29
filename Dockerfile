FROM rabbitmq:3-management

RUN apt-get update \
    && apt-get install openssl \
    && mkdir -p /opt/healthcatalyst/testca \
    && apt-get install tofrodos \
    && ln -s /usr/bin/fromdos /usr/bin/dos2unix

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

