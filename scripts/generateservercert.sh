#!/bin/bash

set -eu

#
# Prepare the certificate authority (self-signed).
#
cd /opt/healthcatalyst/testca

#
# Prepare the server's stuff.
#
cd /opt/healthcatalyst/server

# Generate a private RSA key.
openssl genrsa -out key.pem 2048

# Generate a certificate from our private key.
openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=$(hostname)/O=server/ -nodes

# Sign the certificate with our CA.
cd /opt/healthcatalyst/testca
openssl ca -config openssl.cnf -in /opt/healthcatalyst/server/req.pem -out /opt/healthcatalyst/server/cert.pem -notext -batch -extensions server_ca_extensions

# Create a key store that will contain our certificate.
cd /opt/healthcatalyst/server
openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:roboconf
