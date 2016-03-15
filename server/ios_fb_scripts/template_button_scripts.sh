#!/bin/bash
# $1 is the section
# $2 is the index

# output: 2 scripts for getting coordinates of button and clicking it
cat select_item.tmp.cy | sed -e s/\$0/$1/ -e s/\$1/$2/ > select_item_${1}_${2}.cy
cat press_ad_options.tmp.cy | sed -e s/\$0/$1/ -e s/\$1/$2/ > press_ad_options_${1}_${2}.cy
cat determine_ad_carousel.tmp.cy | sed -e s/\$0/$1/ -e s/\$1/$2/ > determine_ad_carousel_${1}_${2}.cy