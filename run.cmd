docker stop fabric.realtime.rabbitmq
docker rm fabric.realtime.rabbitmq
docker volume rm rabbitmqstore
docker volume create rabbitmqstore

docker build -t healthcatalyst/fabric.realtime.rabbitmq . 
docker run -P -v rabbitmqstore:/opt/rabbitmq/ --rm -e RABBITMQ_MNESIA_BASE=/opt/rabbitmq -e CERT_PASSWORD=mypassword -e RABBITMQ_MGMT_UI_PASSWORD=mypassword --name fabric.realtime.rabbitmq -t healthcatalyst/fabric.realtime.rabbitmq