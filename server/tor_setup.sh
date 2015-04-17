#!/bin/bash
cat <<EOF >> /etc/apt/sources.list
deb http://deb.torproject.org/torproject.org trusty main
deb-src http://deb.torproject.org/torproject.org trusty main
EOF

gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

apt-get update
apt-get -y install tor deb.torproject.org-keyring

cat <<EOF2 >> /etc/tor/torrc
ExitNodes {us}

SocksListenAddress `hostname -I`
SocksPolicy accept *
EOF2

service tor restart