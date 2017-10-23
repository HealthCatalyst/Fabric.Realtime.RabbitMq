docker stop fabric.realtime.rabbitmq
docker rm fabric.realtime.rabbitmq
docker build -t healthcatalyst/fabric.realtime.rabbitmq . 
docker run -P --rm -e CERT_PASSWORD=mypassword -e RABBITMQ_MGMT_UI_PASSWORD=mypassword --name fabric.realtime.rabbitmq -t healthcatalyst/fabric.realtime.rabbitmq