#!/bin/bash

find /tmp/ -mtime +0 \( -name '*.decrypted' -or -name '*.classdump.txt' -or -name '*.tree.txt' -or -name '*.strings.txt' -or -name '*_decrypted' \) | xargs rm -rf
