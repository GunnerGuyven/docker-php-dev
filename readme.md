# Docker Based PHP Development Environment

This is a collection of dockerfiles, scripts, settings, and a compose file tying them largely together to create a mostly ready-to-go environment for development.

## Database

Script added to import. Not taking advantage of the auto-setup scripting feature of these images to be slightly more flexible, and to deal with situations where imports should or shouldn't happen at the user's discretion (and can be very expensive in my case).

To import, uncomment the extra lines in this section of `docker-compose.yml`:

```yaml
volumes:
  - mydb:/var/lib/mysql
  # - ./temp/my_sync_db:/temp/sync_db
  # - ./sync_db.sh:/sync_db.sh
  # - ./my.cnf:/etc/mysql/my.cnf
```

The included `my.cnf` file adds settings that expands memory for the database engine.  This allows very large imports to benefit from significantly better performance.

To run it use the command:

```console
$ docker exec -it docker-php-dev_my_db_1 bash sync_db.sh -h
A helper for syncing local data from remote
Usage: sync_db.sh [-r|--host <arg>] [-u|--user <arg>] [-p|--pass <arg>] [-g|--(no-)go] [-d|--(no-)skip-download] [-i|--(no-)skip-import] [--(no-)psql] [--(no-)maria] [--(no-)locale-fix] [--(no-)include-roles] [-h|--help] [<dbname-1>] ... [<dbname-n>] ...
        <dbname>: The database name(s) we are importing
        -r, --host: Remote database host (no default)
        -u, --user: Remote database user (no default)
        -p, --pass: Remote database password (no default)
        -g, --go, --no-go: Perform import (off by default)
        -d, --skip-download, --no-skip-download: Skip download step (off by default)
        -i, --skip-import, --no-skip-import: Skip import step (off by default)
        --psql, --no-psql: Use PostgreSQL mode (off by default)
        --maria, --no-maria: Use MariaDB mode (off by default)
        --locale-fix, --no-locale-fix: Replace known Windows locale with Unix (PostgreSQL only) (on by default)
        --include-roles, --no-include-roles: Grab all roles from target server (PostgreSQL only) (off by default)
        -h, --help: Prints help
```

Examine your environment for the proper container name in the above command.

When you choose to execute you'll see a result such as:

```console
$ docker exec -it docker-php-dev_my_db_1 bash sync_db.sh -r backup.remote.com central --go

Retrieving size information for remote database(s) 'central'
+----------+---------+-----------+-----------+
| Database | #Tables | #Rows (M) | Size (Mb) |
+----------+---------+-----------+-----------+
| central  |      16 |    0.0187 |    3.3393 |
+----------+---------+-----------+-----------+

Performing download of 'central'
  central: 1.81MiB 0:00:05 [ 338KiB/s]

Compiling result
1.81MiB 0:00:00 [88.5MiB/s] [=========================================>] 100% 

Importing data to local database
  central: 1.81MiB 0:00:00 [ 133MiB/s] [==============================>] 100%
```

Naturally, edit this script to your needs.

### Permissions

It may be necessary to grant permission to use the data you import to the user you wish to use.  An example of this is here for reference:

```mysql
grant all privileges on *.* to 'mydb'@'%';
```

### Script utility Argbash

A freeware utility called Argbash was used to help generate this script specifically for argument parsing logic.  This was a great time-saver on what is easily one of the most complex elements of bash scripting.  The utility can be found at [https://argbash.dev/] and is engaged by editing the header comments in the script to specification of the API described by the project's documentation and rerunning with this scriptfile as input and output such as:

```console
argbash sync_db.sh -o sync_db.sh
```

### Postgres connection from very old clients

Postgres v10 moved to a default SCRAM method for login that is unsupported in pgsql clients that are older (such as those included in the php 5.5 dockerfile in this project).  These clients are able to be supported by enabling the overrides for `postgresql.conf` and `pg_hba.conf` that have been included, but this presents a challenge during setup.

When starting from a clean data volume for Postgres do not include these file overrides as they will confound the first-time-setup process.

```yaml
    volumes:
      - pgdb:/var/lib/postgresql/data
      # - ./pg15-postgresql.conf:/var/lib/postgresql/data/postgresql.conf
      # - ./pg15-pg_hba.conf:/var/lib/postgresql/data/pg_hba.conf
```

After setup is complete and the engine is accessible, you must restart the container with these config file mounts added, and then reset the password of the user in question to cause its password storage hash to be recalculated to the older standard.

```console
$ docker exec -it docker-php-dev-pg_db-1 psql -U pgdb
psql (15.5 (Debian 15.5-1.pgdg120+1))
Type "help" for help.

pgdb=# ALTER USER pgdb WITH PASSWORD 'abc123';
ALTER ROLE
pgdb=# exit;
```

Restart the Postgres container once more and you should be set.  Replace the usernames and passwords above with those you have chosen.

## Configuration

Launching docker compose with the `-f` flag allows you to specify a number of configurations which will be applied in order.  Using this, you can supply modifications to the given docker-compose.yml in a separate file for convenience.

## Trigger PHP Debugging Manually

XDEBUG_SESSION_START=session_name
