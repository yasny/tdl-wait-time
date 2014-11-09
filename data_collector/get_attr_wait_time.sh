#!/bin/bash
BASE_DIR="/home/ec2-user/disney"
DL_OUT_DIR="${BASE_DIR}/tdl"
DS_OUT_DIR="${BASE_DIR}/tds"

datetime=$( TZ="Asia/Tokyo" date +"%Y-%m-%d %H:%M" )
file_datetime=$( TZ="Asia/Tokyo" date +%Y%m%d%H%M )

out="${DL_OUT_DIR}/attr_wait_${file_datetime}.htm"
curl -s -o $out -f  "http://s.tokyodisneyresort.jp/tdl/atrc_list.htm"

if [ -f $out ]; then
  xsltproc --html --param datetime "\"$datetime\"" ${BASE_DIR}/disneyland_atr_wait_time.xslt $out 2>/dev/null > ${DL_OUT_DIR}/attr_wait_${file_datetime}.dat
fi

out="${DS_OUT_DIR}/attr_wait_${file_datetime}.htm"
curl -s -o $out -f  "http://s.tokyodisneyresort.jp/tds/atrc_list.htm"

if [ -f $out ]; then
  xsltproc --html --param datetime "\"$datetime\"" ${BASE_DIR}/disneyland_atr_wait_time.xslt $out 2>/dev/null > ${DS_OUT_DIR}/attr_wait_${file_datetime}.dat
fi

