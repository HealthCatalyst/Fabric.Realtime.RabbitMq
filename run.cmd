docker stop fabric.realtime.rabbitmq
docker rm fabric.realtime.rabbitmq
docker build -t healthcatalyst/fabric.realtime.rabbitmq . 
docker run -P --rm --hostname=fabric.realtime.rabbitmq --name fabric.realtime.rabbitmq -t healthcatalyst/fabric.realtime.rabbitmq