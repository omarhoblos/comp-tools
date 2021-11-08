# Comp Tools

A set of tools I use for getting setup on any dev machine

NOTE - these scripts are intended for testing & development use only. They are not intended for production.

## Usage

### Mongo

For `mongo-docker.sh`, pass the operation type (`install` or `cleanup`), the directory that your `mongo-data` sits in (or should be created), and a password (if installing):

`./mongo-docker.sh -o install -p mypassword -d /home/omarhoblos/`

`sudo ./mongo-docker.sh -o clean -d /home/omarhoblos/`

NOTE - to delete the `mongo-data` volume, the script needs to be run with `sudo`. This is due to Docker changing folder ownership to the root user, thus making it so the user in session can't modify it without sudo privileges.

### PostgresSQL

Run the `psql-docker.sh` script to create a default db as per the on the [official Docker Hub](https://hub.docker.com/_/postgres) page
