#!/bin/bash
sudo su
sudo apt-get install tinyproxy  
sed -i -e 's/Allow\ 127.0.0.1/#Allow\ 127.0.0.1/g' /etc/tinyproxy.conf
sudo service tinyproxy restart