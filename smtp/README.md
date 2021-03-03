# Adding SMTP Relay to XNAT Docker Compose #

This uses the [freinet/postfix-relay](https://hub.docker.com/r/freinet/postfix-relay) image to provide a locally accessible SMTP
relay service. This makes it relatively easy to configure your XNAT to send emails without having to mess with configuring the
SMTP server through XNAT's user interface.

The following environment variables are configured in the [default.env file](../default.env). The **Image variable** column
indicates the environment variables on the Postfix Docker image to which `xnat-docker-compose` environment variables are
mapped.

Variable | Description | Image variable
-------- | ----------- | -------------
REMOTE_SMTP_DOMAIN | Indicates the default mail domain from which mail is sent. Note that this isn't the SMTP server, but the domain for email
  _from your XNAT_, so usually your institute or organization's domain. | MAILNAME
REMOTE_SMTP_HOST | Indicates the address of the SMTP server to which emails should be relayed. | Server portion of RELAYHOST and RELAYHOST_PASSWORDMAP
REMOTE_SMTP_PORT | Indicates which port on the SMTP server should be used for relaying emails. This is usually 25 for non-secured SMTP servers and 587 for secured SMTP servers. | Port portion of RELAYHOST
REMOTE_SMTP_ENABLE_AUTH | Indicates whether authentication is required for the configured SMTP server. | RELAYHOST_AUTH
REMOTE_SMTP_USERNAME | Indicates the username to use to authenticate with the configured SMTP server. Has no effect if **REMOTE_SMTP_ENABLE_AUTH** is false. | Username portion of RELAYHOST_PASSWORDMAP
REMOTE_SMTP_PASSWORD | Indicates the password to use to authenticate with the configured SMTP server. Has no effect if **REMOTE_SMTP_ENABLE_AUTH** is false. | Password portion of  RELAYHOST_PASSWORDMAP
REMOTE_SMTP_LOCAL_TZ | Specifies the timezone from which emails are sent. | TZ

The table below shows the variables set on the Docker image and the variables above that comprise each one.

Variable | Composition
-------- | -----------
MAILNAME | ${REMOTE_SMTP_DOMAIN}
TZ | ${REMOTE_SMTP_LOCAL_TZ}
RELAYHOST | ${REMOTE_SMTP_HOST}:${REMOTE_SMTP_PORT}
RELAYHOST_AUTH | ${REMOTE_SMTP_ENABLE_AUTH}
RELAYHOST_PASSWORDMAP | ${REMOTE_SMTP_HOST}:${REMOTE_SMTP_USERNAME}:${REMOTE_SMTP_PASSWORD}
