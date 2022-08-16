# Comp Tools

A set of tools I use for getting setup on any dev machine

NOTE - these scripts are intended for testing & development use only. They are not intended for production.

## Usage

### Mongo deployed with Docker Compose

1. cd into mongo folder

2. Modify the env file or create your own

3. To start container `docker-compose --env-file env.dev up -d` , make sure to specify correct env file

4. To stop container `docker-compose up -d`  (database data will not be deleted)

5. To stop and remove all data volumes and images on machine `docker-compose down --rmi -v`  (database data folder will not be deleted - this needs to be done manually)

### Mongo deployed in Docker (Using Scripts - old method)

For `mongo-docker.sh`, pass the operation type (`install` or `cleanup`), the directory that your `mongo-data` sits in (or should be created), and a password (if installing):

`./mongo-docker.sh -o install -p mypassword -d /home/omarhoblos/`

`sudo ./mongo-docker.sh -o clean -d /home/omarhoblos/`

NOTE - to delete the `mongo-data` volume, the script needs to be run with `sudo`. This is due to Docker changing folder ownership to the root user, thus making it so the user in session can't modify it without sudo privileges.

### PostgresSQL deployed in Docker 

Run the `psql-docker.sh` script to create a default db as per the instructions on the [official Docker Hub](https://hub.docker.com/_/postgres) page

You'll be presented with two options:

i (or install) - downloads postgres & creates a volume in the `$HOME` directory where the data is store

c (or cleanup) - deletes the container & volume created. Useful if you want to start from scratch

### Making backups using Postgres & Docker

Often you'll run into a case where you want to backup your DB, just to check a change or undo a write. Because this script mounts a volume on your computer, this means creating a new container is not an option, since the new container (assuming you mount the same volume) will still have all the data previously written to it. To manage that, you can run `pg_dump` using `docker exec`.

_Backing up_

```console
docker exec -t postgres pg_dumpall -c -U postgres > dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql
```

_Restoring_

```console
cat your_dump.sql | docker exec -i your-db-container psql -U your-db-user -d your-db-name
```

### Credits

Thank you to the following for their contributions:

[Elie Maamari](https://github.com/eliemaamari1) for his re-write of the mongo deployment scripts
