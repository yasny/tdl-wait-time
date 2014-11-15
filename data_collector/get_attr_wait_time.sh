#!/bin/bash
BASE_DIR="$( dirname $0 )"
DL_OUT_DIR="${BASE_DIR}/tdl"
DS_OUT_DIR="${BASE_DIR}/tds"

_temp_html=$( mktemp `basename $0`.XXXX )

function cleanup {
  [ -f $_temp_html ] && rm -rf $_temp_html
}
trap cleanup EXIT

if [[ ! -d $DL_OUT_DIR ]]; then
  mkdir $DL_OUT_DIR
fi

if [[ ! -d $DS_OUT_DIR ]]; then
  mkdir $DS_OUT_DIR
fi

datetime=$( TZ="Asia/Tokyo" date +"%Y-%m-%d %H:%M" )
file_datetime=$( TZ="Asia/Tokyo" date +%Y%m%d%H%M )

out="${DL_OUT_DIR}/attr_wait_${file_datetime}.htm"
curl -s -o $_temp_html -f  "http://s.tokyodisneyresort.jp/tdl/atrc_list.htm"
cat $_temp_html | sed 's/h2 class="themeName"><p>\(.*\)<\/p>/h2 class="themeName">\1/' > $out

if [ -f $out ]; then
  xsltproc --html --param datetime "\"$datetime\"" ${BASE_DIR}/disneyland_atr_wait_time.xslt $out 2>/dev/null > ${DL_OUT_DIR}/attr_wait_${file_datetime}.dat
fi

out="${DS_OUT_DIR}/attr_wait_${file_datetime}.htm"
curl -s -o $_temp_html -f  "http://s.tokyodisneyresort.jp/tds/atrc_list.htm"
cat $_temp_html | sed 's/h2 class="themeName"><p>\(.*\)<\/p>/h2 class="themeName">\1/' > $out

if [ -f $out ]; then
  xsltproc --html --param datetime "\"$datetime\"" ${BASE_DIR}/disneyland_atr_wait_time.xslt $out 2>/dev/null > ${DS_OUT_DIR}/attr_wait_${file_datetime}.dat
fi

$BASE_DIR/insert_wait_time_into_db.sh $DL_OUT_DIR/attr_wait_${file_datetime}.dat
if [ $? -ne 0 ]; then
  logger "Error occured inserting data into database for file ${DL_OUT_DIR}/attr_wait_${file_datetime}.dat"
else
  rm -rf $DL_OUT_DIR/attr_wait_${file_datetime}.dat
  rm -rf $DL_OUT_DIR/attr_wait_${file_datetime}.htm
fi

$BASE_DIR/insert_wait_time_into_db.sh $DS_OUT_DIR/attr_wait_${file_datetime}.dat
if [ $? -ne 0 ]; then
  logger "Error occured inserting data into database for file ${DS_OUT_DIR}/attr_wait_${file_datetime}.dat"
else
  rm -rf $DS_OUT_DIR/attr_wait_${file_datetime}.dat
  rm -rf $DS_OUT_DIR/attr_wait_${file_datetime}.htm
fi

