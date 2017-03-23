#!/bin/bash

# Expects to be run from the root directory of varys
# $1 is the ip address of the device

scp ./server/ios_utils/dumpdecrypted_10_2.dylib root@$1:~/dumpdecrypted.dylib
scp ./server/ios_utils/move_decrypted.sh root@$1:~/
