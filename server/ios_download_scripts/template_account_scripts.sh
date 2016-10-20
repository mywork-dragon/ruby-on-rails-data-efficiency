#!/bin/bash
# $1 is apple_id
# $2 is the password

cat sign_in.tmp.cy | sed -e s/\$0/$1/ -e s/\$1/$2/ > sign_in.cy
cat check_sign_in.tmp.cy | sed -e s/\$0/$1/ > check_sign_in.cy