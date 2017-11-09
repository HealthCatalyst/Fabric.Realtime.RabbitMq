# Fabric.Docker.RabbitMQ
[RabbitMQ](https://www.rabbitmq.com/) Docker instance for use with the [Health Catalyst](https://www.healthcatalyst.com) [Fabric.Realtime](https://github.com/HealthCatalyst/Fabric.Realtime) platform.

This image delivers RabbitMQ on Linux and automates the following:
* Generation of X.509 certificates for SSL and client certificate-based authentication
* Configuration of SSL
* User creation
* Updating components, such as Erlang

## Run Fabric.Docker.RabbitMQ

Standalone
```
docker run -P -v rabbitmqstore:/opt/rabbitmq/ --rm -e DISABLE_SSL=no -e RABBITMQ_MNESIA_BASE=/opt/rabbitmq -e RABBITMQ_MGMT_UI_PASSWORD=<mypassword> --name fabric.realtime.rabbitmq -t healthcatalyst/fabric.realtime.rabbitmq
```

You will be prompted for the following:

* Please type in hostname to use for SSL certificate:
* Please type in password to use for client certificate:
* Please type in password to use with admin user for RabbitMq Admin UI:

After deployment, you can access the RabbitMQ Management Web UI by navigating to `https://<fqdn-swarm-manager>:15672` in your browser.

# Ports
The following inbound ports must be opened to the Docker swarm manager for communication with RabbitMQ:
* 8081 (X.509 certificate server)
* 5671 (RabbitMQ SSL Listener)
* 15672 (RabbitMQ Management Web UI)
