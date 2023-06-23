# What's happening here

This represents an attempt to create a development environment for testing php code that is closer to what we have in production while also being accessible on machines where php 5.x is difficult to install.

## Database

Script added to import. Not taking advantage of the auto-setup scripting feature of these images to be slightly more flexible, and to deal with situations where imports should or shouldn't happen at the user's discretion (and can be very expensive in my case).

To import, uncomment the extra lines in this section of `docker-compose.yml`:

```yaml
volumes:
  - mydb:/var/lib/mysql
  # - ./temp/db_import:/db_import_temp
  # - ./sync_db.sh:/db_import_temp/sync_db.sh
  # - ./my.cnf:/etc/mysql/my.cnf
```

The included `my.cnf` file adds settings that expands memory for the database engine.  This allows very large imports to benefit from significantly better performance.

To run it use the command:

```console
$ docker exec -it docker-php-dev_my_db_1 bash sync_db.sh -h
A helper for syncing local data from remote
Usage: ./sync_db.sh [-r|--host <arg>] [-u|--user <arg>] [-p|--pass <arg>] [-g|--(no-)go] [-d|--(no-)skip-download] [-i|--(no-)skip-import] [--(no-)psql] [--(no-)locale-fix] [--(no-)include-roles] [-h|--help] [<dbname-1>] ... [<dbname-n>] ...
        <dbname>: The name of the database we are importing
        -r, --host: Remote database host (no default)
        -u, --user: Remote database user (no default)
        -p, --pass: Remote database password (no default)
        -g, --go, --no-go: Perform import (off by default)
        -d, --skip-download, --no-skip-download: Skip download step (off by default)
        -i, --skip-import, --no-skip-import: Skip import step (off by default)
        --psql, --no-psql: Use PostgreSQL instead of MySQL (off by default)
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
1.81MiB 0:00:05 [ 338KiB/s]
Importing data to local database
 240KiB 0:00:00 [ 133MiB/s] [==============================>] 100%
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

## TODO

- [x] Create a mechanism to specify one or several directories that can be made writable by the PHP process.
    - Expectation is to use an ENV variable that is a list of paths delimited by semi-colon
    - This can be useful for template generators like Smarty that need a directory to do their work in.
    - The alternative is to require the user to create a directory on a mount and give it wide permissions (+777) to accomplish this, but that is a tedium and insists on the external management of this dir (it may be desired that the directory is ephemerial and internally managed, for instance).
