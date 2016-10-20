#!/bin/bash

# expects %0 to be templated
# %0 could have strange characters in it

DYLD_INSERT_LIBRARIES=/var/root/dumpdecrypted.dylib "%0" mach-o decryption dumper
