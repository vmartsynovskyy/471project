FROM nginx

RUN apt-get update && apt-get install iproute2 -y

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /home/root/entrypoint.sh

ENV NGINX_USER=www-data \
    NGINX_SITECONF_DIR=/etc/nginx/sites-enabled \
    NGINX_LOG_DIR=/var/log/nginx \
    NGINX_TEMP_DIR=/var/lib/nginx


ENTRYPOINT ["/home/root/entrypoint.sh"]

