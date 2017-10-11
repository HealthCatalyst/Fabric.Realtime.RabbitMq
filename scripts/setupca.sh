#!/bin/bash

set -eu

#
# Prepare the certificate authority (self-signed).
#
cd /opt/healthcatalyst/testca

# Create a self-signed certificate that will serve a certificate authority (CA).
# The private key is located under "private".
openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 3650 -out cacert.pem -outform PEM -subj /CN=FabricRabbitMqCA/ -nodes

# Encode our certificate with DER.
openssl x509 -in cacert.pem -out cacert.cer -outform DER
