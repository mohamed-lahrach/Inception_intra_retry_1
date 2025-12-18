FROM debian:bullseye

RUN apt update && apt install -y nginx  openssl

COPY	conf/nginx.conf /etc/nginx/sites-available/default
RUN     chmod 777 /etc/nginx/sites-available/default

EXPOSE 443

COPY tools/setupssl.sh /usr/local/bin/setupssl.sh
RUN chmod +x /usr/local/bin/setupssl.sh


CMD ["/usr/local/bin/setupssl.sh"]

