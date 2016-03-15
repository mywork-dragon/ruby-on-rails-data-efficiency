#!/bin/bash

find /var/mobile/Media/DCIM/100APPLE -mindepth 1 -printf '%T+ %p\n' | sort -r | head -n1 | awk '{print $2}'