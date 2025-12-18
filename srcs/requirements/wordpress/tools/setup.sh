#!/bin/bash
set -e

mkdir -p /var/www/wordpress
chown -R www-data:www-data /var/www/wordpress

cd /var/www/wordpress

MARIADB_WORDPRESS_PASSWORD="$(cat /run/secrets/mariadb_wordpress_password)"

WORDPRESS_AUTHOR_PASSWORD="$(cat /run/secrets/wordpress_author_password)"

if [ ! -f "wp-config.php" ]; then
  echo "downloading wordpress core files"
  wp core download --allow-root

  while ! mariadb -h mariadb -u"$WORDPRESS_DB_USER" -p"$MARIADB_WORDPRESS_PASSWORD"; do
      echo "Waiting for MariaDB Connection...";
      sleep 2
  done

  wp config create --allow-root \
    --dbname="$MARIADB_DATABASE" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$MARIADB_WORDPRESS_PASSWORD" \
    --dbhost="$WORDPRESS_DB_HOST"

  echo  "\nInstalling wordpress"

  wp core install --allow-root \
    --url="$WORDPRESS_SITE_URL" \
    --title="$WORDPRESS_SITE_TITLE" \
    --admin_user="$WORDPRESS_DB_USER" \
    --admin_password="$MARIADB_WORDPRESS_PASSWORD" \
    --admin_email="$WORDPRESS_ADMIN_EMAIL"

  wp user create --allow-root \
    "$WORDPRESS_AUTHOR_USER" "$WORDPRESS_AUTHOR_EMAIL" \
    --role=author \
    --user_pass="$WORDPRESS_AUTHOR_PASSWORD"
else
  echo "WordPress already installed, skipping install steps."
fi

echo "\nstarting php-fpm"
exec php-fpm7.4 -F