#!/bin/bash

# echo "----------------------------------------"
# echo "creation testing"
# echo "args: $*"
# echo "----------------------------------------"



while [[ -n $1 ]]; do
case "$1" in
  # force)
  #   shift
  #   force=1
  #   ;;
  drop)
    shift
    drop=1
    ;;
  *)
    shift
esac
done

db=${MARIADB_DATABASE:=mydb}
dbuser=${MARIADB_USER:=mydb}
rpass=${MARIADB_ROOT_PASSWORD:=poi098}

if [[ -n $drop ]]; then
  echo "drop database $db" | mysql -uroot --password="$rpass"
  echo "Database dropped: $db"
fi

{
  echo "create database $db" | mysql -uroot --password="$rpass"
} &> /dev/null
if [[ $? -eq 0 ]]; then
  created=1
  echo "Database created: $db"
# mysql -uroot --password="$rpass" <<-EOSQL
#   GRANT ALL PRIVILEGES ON $db.* TO $dbuser;
# EOSQL
#   echo "Rights granted to user: $dbuser"
fi

if [[ -n $created || -n $force ]]; then
  echo "Importing data..."
  pv /$db.sql.gz | gunzip | mysql -uroot --password="$rpass" $db
else
  echo "Database '$db' already exists."
  # echo "Use argument 'force' to ignore this and import anyway."
  echo "Use argument 'drop' to destroy existing db and import."
fi

# echo