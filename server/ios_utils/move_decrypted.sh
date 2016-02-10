#!/bin/bash

md5=$(md5sum "$1" | head -n1 | awk '{print $1}')
mv -v "$1" $md5.decrypted
