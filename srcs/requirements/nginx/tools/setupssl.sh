#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=MA/ST=BG/L=1337/O=42/OU=42/CN=$NGINX_DOMAIN_NAME"
        
exec nginx -g "daemon off;"