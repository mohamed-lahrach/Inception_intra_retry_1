#!/bin/bash
set -e

chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql

first_time=0
if [ ! -f "/var/lib/mysql/.initialized" ]; then
  touch /var/lib/mysql/.initialized
  first_time=1
fi

service mariadb start

MARIADB_ROOT_PASSWORD="$(cat /run/secrets/mariadb_root_password)"
MARIADB_WORDPRESS_PASSWORD="$(cat /run/secrets/mariadb_wordpress_password)"

while ! mysqladmin ping ; do
    sleep 2
done

if [ "$first_time" = "1" ]; then
  mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"
fi

mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;"
mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${WORDPRESS_DB_USER}'@'%' IDENTIFIED BY '${MARIADB_WORDPRESS_PASSWORD}';"
mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${WORDPRESS_DB_USER}'@'%';"
mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown

exec mysqld