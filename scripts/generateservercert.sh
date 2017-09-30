# generate server keys (https://www.rabbitmq.com/ssl.html)

cd /opt/healthcatalyst
mkdir -p server
cd server
openssl genrsa -out key.pem 2048
openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=$1/O=server/ -nodes
cd ../testca
openssl ca -config openssl.cnf -in ../server/req.pem -out ../server/cert.pem -notext -batch -extensions server_ca_extensions
cd ../server
openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:MySecretPassword

