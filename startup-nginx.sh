#!/usr/bin/env sh

set -x

chown -R www-data:www-data /var/www/rutorrent
mkdir -p /torrents/config/rutorrent/torrents
printf "${RUTORRENT_USER}:$(openssl passwd -crypt ${RUTORRENT_PASSWORD})\n" >> /torrents/config/.htpasswd
chown -R www-data:www-data /torrents/config/rutorrent
mkdir -p /torrents/config/log/nginx
chown www-data:www-data /torrents/config/log/nginx

rm -f /etc/nginx/sites-enabled/*

rm -rf /etc/nginx/ssl

rm /var/www/rutorrent/.htpasswd


# Basic auth enabled by default
site=rutorrent-basic.nginx

# Check if TLS needed
if [ -e /torrents/config/nginx.key ] && [ -e /torrents/config/nginx.crt ]; then
    mkdir -p /etc/nginx/ssl
    cp /torrents/config/nginx.crt /etc/nginx/ssl/
    cp /torrents/config/nginx.key /etc/nginx/ssl/
    site=rutorrent-tls.nginx
fi

cp /root/$site /etc/nginx/sites-enabled/
[ -n "$NOIPV6" ] && sed -i 's/listen \[::\]:/#/g' /etc/nginx/sites-enabled/$site
[ -n "$WEBROOT" ] && ln -s /var/www/rutorrent /var/www/rutorrent/$WEBROOT
sed -i 's#localhost#'${EXTERNAL_DOMAIN}'#g' /etc/nginx/sites-enabled/$site
sed -i 's#https://##g' /etc/nginx/sites-enabled/$site

# Check if .htpasswd presents
if [ -e /torrents/config/.htpasswd ]; then
    cp /torrents/config/.htpasswd /var/www/rutorrent/ && chmod 755 /var/www/rutorrent/.htpasswd && chown www-data:www-data /var/www/rutorrent/.htpasswd
else
# disable basic auth
    sed -i 's/auth_basic/#auth_basic/g' /etc/nginx/sites-enabled/$site
fi

nginx -g "daemon off;"

