#!/bin/bash
# $1 is the templating type (0 for find, 1 for bundle info)
# $2 is the variable to be scripted. Each template only has 1 variable for templating
# $3 is the output path


if [ $1 == "0" ]; then
        cat decrypt_find.tmp.sh | sed -e "s#%0#$2#" > $3
else
        # use different delimeter because expecting file paths
        cat decrypt_bundle.tmp.sh | sed -e "s#%0#$2#" > $3
fi

chmod a+x $3
