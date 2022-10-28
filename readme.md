# What's happening here

This represents an attempt to create a development environment for testing php code that is closer to what we have in production while also being accessible on machines where php 5.x is difficult to install.

## Database

Script added to import. Not taking advantage of the auto-setup scripting feature of these images to be slightly more flexible, and to deal with situations where imports should or shouldn't happen at the user's discretion (and can be very expensive in my case).

To import, uncomment all three lines in this section of `docker-compose.yml`:

```yaml
volumes:
  - mydb:/var/lib/mysql
  # - ./create_mysql.sh:/create_mysql.sh
  # - ./my.cnf:/etc/mysql/my.cnf
  # - ./mydb.sql.gz:/mydb.sql.gz
```

The database name is taken from `MARIADB_DATABASE` env variable, and should match the import file `<database name>.sql.gz`

The included `my.cnf` file adds settings that expands memory for the database engine.  This allows very large imports to benefit from significantly better performance.

As stated before, this script does not automatically execute.  To run it use the command:

```console
$ docker exec -it docker-php-dev_my_db_1 bash create_mysql.sh
Database 'mydb' already exists.
Use argument 'drop' to destroy existing db and import.
```

Examine your environment for the proper container name in the above command.

<!-- If you use the built-in mechanism provided by the mysql image to create a database for you (and permission the given user to it) you may wish to use the 'force' argument to ignore that the database already exists and perform the import anyway. -->

If you choose to use the 'drop' argument the database will be destroyed and recreated from scratch.

```console
$ docker exec -it docker-php-dev_my_db_1 bash create_mysql.sh drop
Database dropped: mydb
Database created: mydb
Importing data...
90.1MiB 0:02:09 [1.03MiB/s] [==>                 ] 12% ETA 0:15:14
```

Naturally, edit this script to your needs.

## TODO

- Create a mechanism to specify one or several directories that can be made writable by the PHP process.
    - Expectation is to use an ENV variable that is a list of paths delimited by semi-colon
    - This can be useful for template generators like Smarty that need a directory to do their work in.
    - The alternative is to require the user to create a directory on a mount and give it wide permissions (+777) to accomplish this, but that is a tedium and insists on the external management of this dir (it may be desired that the directory is ephemerial and internally managed, for instance).

