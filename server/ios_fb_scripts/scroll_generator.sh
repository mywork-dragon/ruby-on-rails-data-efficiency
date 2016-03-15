#!/bin/bash
# $1 is the section of the feed
# $2 is the number of items in the feed

# output: N scripts for scrolling and checking the specific row in the feed

i=0

while [ $i -lt $2 ]
do
	cat item_check.tmp.cy | sed -e s/\$0/$1/ -e s/\$1/$i/ > ${i}_check.cy
	cat item_scroll.tmp.cy | sed -e s/\$0/$1/ -e s/\$1/$i/ > ${i}_scroll.cy
	cat item_refresh.tmp.cy | sed -e s/\$0/$1/ -e s/\$1/$i/ > ${i}_refresh.cy
    cat item_bottom_scroll.tmp.cy | sed -e s/\$0/$1/ -e s/\$1/$i/ > ${i}_bottom_scroll.cy
	((i+=1))
done