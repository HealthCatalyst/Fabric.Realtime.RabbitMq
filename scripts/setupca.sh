# set up CA Certificate Authority

cd /opt/healthcatalyst/testca
mkdir certs private
chmod 700 private
echo 01 > serial
touch index.txt
openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 365 -out cacert.pem -outform PEM -subj /CN=MyTestCA/ -nodes
openssl x509 -in cacert.pem -out cacert.cer -outform DER
