# get root password

echo "create database mydb" | mysql --password='poi098'
mysql --password='poi098' mydb < /mydb.sql