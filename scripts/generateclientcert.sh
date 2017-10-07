#!/bin/bash

set -eu

#
# Prepare the client's stuff.
#
cd /opt/healthcatalyst/client

# Generate a private RSA key.
openssl genrsa -out key.pem 2048

# Generate a certificate from our private key.
openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=fabricrabbitmquser/O=client/ -nodes

# Sign the certificate with our CA.
cd /opt/healthcatalyst/testca
openssl ca -config openssl.cnf -in /opt/healthcatalyst/client/req.pem -out /opt/healthcatalyst/client/cert.pem -notext -batch -extensions client_ca_extensions

# Create a key store that will contain our certificate.
cd /opt/healthcatalyst/client
openssl pkcs12 -export -out fabric_rabbitmq_client_cert.p12 -in cert.pem -inkey key.pem -passout pass:roboconf

# Create a trust store that will contain the certificate of our CA.
openssl pkcs12 -export -out fabric_rabbitmq_ca_cert.p12 -in /opt/healthcatalyst/testca/cacert.pem -inkey /opt/healthcatalyst/testca/private/cakey.pem -passout pass:roboconf
