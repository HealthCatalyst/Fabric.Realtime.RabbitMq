docker stop fabric.realtime.rabbitmq
docker rm fabric.realtime.rabbitmq
docker build -t healthcatalyst/fabric.realtime.rabbitmq . 
docker create volume rabbitmqstore
docker run -P -v rabbitmqstore:/opt/rabbitmq/ --rm -e RABBITMQ_MNESIA_BASE=/opt/rabbitmq -e CERT_PASSWORD=mypassword -e RABBITMQ_MGMT_UI_PASSWORD=mypassword --name fabric.realtime.rabbitmq -t healthcatalyst/fabric.realtime.rabbitmq