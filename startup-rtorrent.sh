#!/usr/bin/env sh

set -x

# set rtorrent user and group id
RT_UID=${USR_ID:=1000}
RT_GID=${GRP_ID:=1000}

# update uids and gids
groupadd -g $RT_GID rtorrent
useradd -u $RT_UID -g $RT_GID -d /home/rtorrent -m -s /bin/bash rtorrent

# arrange dirs and configs
mkdir -p /torrents/downloading
mkdir -p /torrents/completed
mkdir -p /torrents/watch

chown -R rtorrent:rtorrent /torrents/downloading
chown -R rtorrent:rtorrent /torrents/completed
chown -R rtorrent:rtorrent /torrents/watch

mkdir -p /torrents/config/rtorrent/session
mkdir -p /torrents/config/log/rtorrent
if [ ! -e /torrents/config/rtorrent/.rtorrent.rc ]; then
    cp /root/.rtorrent.rc /torrents/config/rtorrent/
fi
ln -s /torrents/config/rtorrent/.rtorrent.rc /home/rtorrent/
chown -R rtorrent:rtorrent /torrents/config/rtorrent
chown -R rtorrent:rtorrent /home/rtorrent
chown -R rtorrent:rtorrent /torrents/config/log/rtorrent

rm -f /torrents/config/rtorrent/session/rtorrent.lock

sed -i 's#http://mydomain.com#'${EXTERNAL_DOMAIN}'/no-auth#g' /var/www/rutorrent/plugins/fileshare/conf.php
sed -i /getConfFile/d /var/www/rutorrent/plugins/fileshare/share.php

# run
su --login --command="TERM=xterm rtorrent" rtorrent 

