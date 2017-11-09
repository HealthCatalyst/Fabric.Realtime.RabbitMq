# Fabric.Docker.RabbitMQ
[RabbitMQ](https://www.rabbitmq.com/) Docker instance for use with the [Health Catalyst](https://www.healthcatalyst.com) [Fabric.Realtime](https://github.com/HealthCatalyst/Fabric.Realtime) platform.

This image delivers RabbitMQ on Linux and automates the following:
* Generation of X.509 certificates for SSL and client certificate-based authentication
* Configuration of SSL
* User creation
* Updating components, such as Erlang

## Deployment

As this image is intended for deployment as part of the Fabric.Realtime platform, please refer to the set of instructions at https://github.com/HealthCatalyst/Fabric.Realtime.

# Ports
The following inbound ports must be opened to the Docker swarm manager for communication with RabbitMQ:
* 8081 (X.509 certificate server)
* 5671 (RabbitMQ SSL Listener)
* 15672 (RabbitMQ Management Web UI)
