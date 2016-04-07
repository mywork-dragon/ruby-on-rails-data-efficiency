#!/bin/bash

find /var/mobile/Media/DCIM -mindepth 2 -path "*APPLE/*" -printf '%T+ %p\n' | sort -r | head -n1 | awk '{print $2}'
