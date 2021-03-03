# Adding External ActiveMQ to XNAT Docker Compose #

This uses the [webcenter/activemq](https://hub.docker.com/r/webcenter/activemq) image to provide a locally accessible ActiveMQ
service. This is useful to test multi-node XNAT configurations, where the external message queue enables coordination and
distribution of processing tasks across the nodes.

The following environment variables are configured in the [default.env file](../default.env).=

Variable | Description | Default value
-------- | ----------- | -------------
ACTIVEMQ_ADMIN_LOGIN | Indicates the username of the `administrator` account. | admin
ACTIVEMQ_ADMIN_PASSWORD | Indicates the password for the `administrator` account. | password
ACTIVEMQ_WRITE_LOGIN | Indicates the username of an account with write access to the messaging queue. | write
ACTIVEMQ_WRITE_PASSWORD | Indicates the password for the account with write access to the messaging queue. | password
ACTIVEMQ_READ_LOGIN | Indicates the username of an account with read access to the messaging queue. | write
ACTIVEMQ_READ_PASSWORD | Indicates the password for the account with read access to the messaging queue. | password
ACTIVEMQ_JMX_LOGIN | Indicates the username of an account with [JMX access](https://activemq.apache.org/jmx.html) to the messaging queue. | jmx
ACTIVEMQ_JMX_PASSWORD | Indicates the password for the account with [JMX access](https://en.wikipedia.org/wiki/Java_Management_Extensions) to the messaging queue. | password
ACTIVEMQ_MIN_MEMORY | Specifies the minimum amount of memory available to the ActiveMQ service. | 512
ACTIVEMQ_MAX_MEMORY | Specifies the maximum amount of memory available to the ActiveMQ service. | 2048
