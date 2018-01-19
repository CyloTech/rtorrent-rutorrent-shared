#!/usr/bin/env sh

set -x

chown -R www-data:www-data /var/www/rutorrent
printf "${RUTORRENT_USER}:$(openssl passwd -crypt ${RUTORRENT_PASSWORD})\n" >> /data/torrents/config/.htpasswd
mkdir -p /data/torrents/config/rtorrent/torrents
chown -R www-data:www-data /data/torrents/config/rtorrent
mkdir -p /data/torrents/config/log/rtorrent/nginx
chown www-data:www-data /data/torrents/config/log/rtorrent/nginx

rm -f /etc/nginx/sites-enabled/*

rm -rf /etc/nginx/ssl

rm /var/www/rutorrent/.htpasswd


# Basic auth enabled by default
site=rutorrent-basic.nginx

# Check if TLS needed
if [ -e /data/torrents/config/nginx.key ] && [ -e /data/torrents/config/nginx.crt ]; then
    mkdir -p /etc/nginx/ssl
    cp /data/torrents/config/nginx.crt /etc/nginx/ssl/
    cp /data/torrents/config/nginx.key /etc/nginx/ssl/
    site=rutorrent-tls.nginx
fi

cp /root/$site /etc/nginx/sites-enabled/
[ -n "$NOIPV6" ] && sed -i 's/listen \[::\]:/#/g' /etc/nginx/sites-enabled/$site
[ -n "$WEBROOT" ] && ln -s /var/www/rutorrent /var/www/rutorrent/$WEBROOT

# Check if .htpasswd presents
if [ -e /data/torrents/config/.htpasswd ]; then
    cp /data/torrents/config/.htpasswd /var/www/rutorrent/ && chmod 755 /var/www/rutorrent/.htpasswd && chown www-data:www-data /var/www/rutorrent/.htpasswd
else
# disable basic auth
    sed -i 's/auth_basic/#auth_basic/g' /etc/nginx/sites-enabled/$site
fi

nginx -g "daemon off;"

