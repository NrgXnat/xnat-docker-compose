# Adding SMTP Relay to XNAT Docker Compose #

This uses the [freinet/postfix-relay](https://hub.docker.com/r/freinet/postfix-relay) image to provide a locally accessible SMTP
relay service. This makes it relatively easy to configure your XNAT to send emails without having to mess with configuring the 
SMTP server through XNAT's user interface.

The following environment variables are configured in [this project's .env file](../.env):

* **REMOTE_SMTP_DOMAIN**: Specifies the default domain for sending email. Note that this isn't the SMTP server, but the domain for email
  _from your XNAT_, so usually your institute or organization's domain. The default value is **mail.miskatonic.edu**.
* **REMOTE_SMTP_HOST**: Sets the address of the SMTP host. The default value is **smtp.gmail.com**.
* **REMOTE_SMTP_PORT**: Indicates the port for sending emails via the SMTP host. The default value is **587**.
* **REMOTE_SMTP_ENABLE_AUTH**: Configures whether authentication is required to send email via the SMTP host. The default value is **no**.
* **REMOTE_SMTP_USERNAME**: Specifies the username for sending email via the SMTP host (if required). The default value is **username**.
* **REMOTE_SMTP_PASSWORD**: Specifies the password for sending email via the SMTP host (if required). The default value is **password**.
* **REMOTE_SMTP_LOCAL_TZ**: Sets the time zone to use for timestamps when sending emails. The default value is **America/Chicago**.

You can override the default values by specifying them on the command line (note that you probably shouldn't do this for passwords!):

```
REMOTE_SMTP_DOMAIN=bar.edu docker-compose --file docker-compose.yml --file smtp/docker-compose.yml up --detach
```

You can also specify a separate environment variable file:

```
docker-compose --file docker-compose.yml --file smtp/docker-compose.yml --env-file my-vars.env up --detach
```

Note that environment files specified with the **--env-file** option do not combine with the [default .env file](../.env). You must specify
_all_ values in your custom environment variable file. An easy way to do this is to just copy **.env** to your own **_xxx_.env** file then
change or add any environment variables required. 

