#!/bin/bash

find %0 -maxdepth 1 -perm 755 -type f -not -name '*.*' -exec /bin/bash -c "DYLD_INSERT_LIBRARIES=/var/root/dumpdecrypted.dylib '{}' mach-o decryption dumper" \;
