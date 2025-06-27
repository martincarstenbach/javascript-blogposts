# Compose files for Oracle Database 23ai

This directory contains compose files for `docker-compose` and `podman-compose` respectively. Tested using Oracle Linux 9.6 on Linux x86-64 using

- podman 5.4.0
- podman-compose 1.4.0

Oracle Linux 9.6 ships with too old a podman-compose release (1.0.6), make sure to install the current one into a venv, like so:

```sh
python3 -m venv .venv
source .venv/bin/activate
pip3 install podman-compose
podman-compose --version
```

Podman-compose must report at least version 1.4.0.

## If "just a database" is all you need

Use either the following files to create an [Oracle Database 23ai Free](https://www.oracle.com/database/free/) instance:

- compose-docker-db.yml
- compose-podman-db.yml

The latter requires you to create a [Podman secret](https://martincarstenbach.com/2022/12/19/podman-secrets-a-better-way-to-pass-environment-variables-to-containers/), **oracle-passwd**, to set the initial SYS and SYSTEM passwords. Docker doesn't support secrets in the same way, in that case make sure to change the passwords after the initial setup if that's important to you.

Both compose files mount the initialisation directory into the database container, creating a demo account (demouser) for you to play with. This account is also referenced extensively on the blog.

## Oracle REST Data Services and/or APEX

If you want to [REST-enable](https://www.oracle.com/ords) your database or create an [APEX](https://apex.oracle.com) development instance, you can use `compose-apex.yml` for a hands-free setup experience.

ORDS will always be installed. If you want to additionally install APEX, make sure to [download APEX](https://www.oracle.com/tools/downloads/apex-downloads/) from Oracle's website, unzip it in `database/apex` and uncomment line 30 in the compose file to mount the installation directory into the ORDS container.

Note that there is no support for Podman secrets in this compose file, if I can find a way to make them work I'll provide an update.
