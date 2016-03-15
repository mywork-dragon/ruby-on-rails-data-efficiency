#!/bin/bash
# $1 is the section
# $2 is the index
# $3 is the number of ad entries in the scroll

i=0

while [ $i -lt $3 ]
do
    cat swipe_ad.tmp.cy | sed -e s/\$0/$1/ -e s/\$1/$2/ -e s/\$2/$i/ > ${i}_ad_swipe.cy
    ((i+=1))
done