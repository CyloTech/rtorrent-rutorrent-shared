#!/usr/bin/env sh

set -x

# set rtorrent user and group id
RT_UID=${USR_ID:=1000}
RT_GID=${GRP_ID:=1000}

# update uids and gids
groupadd -g $RT_GID rtorrent
useradd -u $RT_UID -g $RT_GID -d /home/rtorrent -m -s /bin/bash rtorrent

# arrange dirs and configs
mkdir -p /data/torrents/config/rtorrent/session
mkdir -p /data/torrents/config/rtorrent/watch
mkdir -p /data/torrents/config/log/rtorrent
if [ ! -e /data/torrents/config/rtorrent/.rtorrent.rc ]; then
    cp /root/.rtorrent.rc /data/torrents/config/rtorrent/
fi
ln -s /data/torrents/config/rtorrent/.rtorrent.rc /home/rtorrent/
chown -R rtorrent:rtorrent /data/torrents/config/rtorrent
chown -R rtorrent:rtorrent /home/rtorrent
chown -R rtorrent:rtorrent /data/torrents/config/log/rtorrent

rm -f /data/torrents/config/rtorrent/session/rtorrent.lock

# run
su --login --command="TERM=xterm rtorrent" rtorrent 

