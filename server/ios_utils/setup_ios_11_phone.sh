#!/bin/bash

# - Turn off Amber and Gov alerts
# - Disable passcode unlock
# - Install apt-get via cydia
# - Change password to padmemyboo
# - Enable all restrictions


apt-get update
apt-get install -y --allow-unauthenticated coreutils findutils sed wget

wget --no-check-certificate https://s3.amazonaws.com/ms-misc/ios-11/ms_bfinject.tar
tar -xvf ms_bfinject.tar
mv ms_bfinject_2/ bfinject

wget --no-check-certificate https://s3.amazonaws.com/ms-misc/ios-11/marco
cp marco /usr/bin/
chmod +x /usr/bin/marco
