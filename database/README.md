# Compose files for Oracle Database 23ai

This directory contains compose files for `docker-compose` and `podman-compose` respectively. Tested using Oracle Linux 9.6 on Linux x86-64 using

- podman 5.4.0
- podman-compose 1.4.0
- Docker 28.4.0
- Docker Compose version v2.39.4

Additional testing on Linux Mint 22 featuring

- podman 4.9.3
- podman-compose 1.4.0

If your distribution ships with too old a podman-compose release (< 1.4), make sure to install the current one into a virtual environment, like so:

```sh
python3 -m venv .venv
source .venv/bin/activate
pip3 install podman-compose
podman-compose --version
```

Podman-compose must report at least version 1.4.x.

All of these files should work, at least they did so on my machine. If you find any problems, please file an issue.

## If "just a database" is all you need

Use either the following files to create an [Oracle Database 23ai Free](https://www.oracle.com/database/free/) instance:

- `compose-docker-db.yml`
- `compose-podman-db.yml`

Both have been updated and require you to provide an `.env` file. This is very easy to do, [here is a blog post](https://martincarstenbach.com/2025/07/30/sourcing-environment-variables-from-env-in-compose/) where the process is described. A sample environment file is available in the repository, simply rename it to `.env` and add your preferred passwords. Prior to bringing the stack up you can use `podman compose -f <the file.yml> config` to validate the configuration.

Both compose files mount the initialisation directory into the database container, creating a demo account (demouser) for you to play with. This account is also referenced extensively on the blog.

## Oracle REST Data Services and/or APEX

If you want to [REST-enable](https://www.oracle.com/ords) your database or create an [APEX](https://apex.oracle.com) development instance, you can use either of these 2 files, depending on your container runtime:

- `compose-podman-ords-apex.yml`
- `compose-docker-ords-apex.yml`

The compose files bring a database instance up (see above) and once the database is ready for use, start the ORDS container which in turn will install/upgrade ORDS in the database.

Note that ORDS will always be installed. If you need to install APEX, make sure to [download APEX](https://www.oracle.com/tools/downloads/apex-downloads/) from Oracle's website, unzip it in `database/apex` and uncomment the volume mount directive in the compose file. This will mount the APEX installation directory into the ORDS container. After the initial APEX installation has completed, you merely need to export the APEX image directory (commented out initially). The container doesn't currently check the APEX minor version and might complain that your installed version doesn't match the one in the volume mount after patching. Further details are in the compose files.
