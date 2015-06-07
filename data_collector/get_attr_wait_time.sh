#!/bin/bash
BASE_DIR="$( dirname $0 )"
DL_OUT_DIR="${BASE_DIR}/tdl"
DS_OUT_DIR="${BASE_DIR}/tds"

_temp_html=$( mktemp `basename $0`.XXXX )

function cleanup {
  [ -f $_temp_html ] && rm -rf $_temp_html
}
trap cleanup EXIT

function syslog_err {
  logger -p user.error -t $( basename $0 ) "$@"
}

function syslog_info {
  logger -p user.info -t $( basename $0 ) "$@"
}

if [[ ! -d $DL_OUT_DIR ]]; then
  mkdir $DL_OUT_DIR
fi

if [[ ! -d $DS_OUT_DIR ]]; then
  mkdir $DS_OUT_DIR
fi

datetime=$( TZ="Asia/Tokyo" date +"%Y-%m-%d %H:%M" )
file_datetime=$( TZ="Asia/Tokyo" date +"%Y%m%d%H%M" )

#========== DISNEYLAND ==========
syslog_info "Getting Disneyland wait times..."
out="${DL_OUT_DIR}/attr_wait_${file_datetime}.htm"
curl -s -o $_temp_html -f -L  "http://info.tokyodisneyresort.jp/rt/s/gps/tdl_index.html?nextUrl=http://info.tokyodisneyresort.jp/rt/s/realtime/tdl_attraction.html&lat=35.6274489&lng=139.8840183"
if [ $? -ne 0 ]; then
  syslog_err "Error occured downloading Disneyland wait list"
  exit 1
fi

sed -E 's/<h2 class="themeName"> *<p>([^<]+)<\/p> */<h2 class="themeName">\1/g' $_temp_html > $out

if [ -f $out ]; then
  xsltproc --html --param datetime "\"$datetime\"" ${BASE_DIR}/disneyland_atr_wait_time.xslt $out 2>/dev/null > ${DL_OUT_DIR}/attr_wait_${file_datetime}.dat
fi

#========== DISNEYSEA ==========
syslog_info "Getting Disney Sea wait times..."
out="${DS_OUT_DIR}/attr_wait_${file_datetime}.htm"
curl -s -o $_temp_html -f -L  "http://info.tokyodisneyresort.jp/rt/s/gps/tds_index.html?nextUrl=http://info.tokyodisneyresort.jp/rt/s/realtime/tds_attraction.html&lat=35.6274489&lng=139.8840183"
if [ $? -ne 0 ]; then
  syslog_err "Error occured downloading Disney Sea wait list"
  exit 1
fi

sed -E 's/<h2 class="themeName"> *<p>([^<]+)<\/p> */<h2 class="themeName">\1/g' $_temp_html > $out

if [ -f $out ]; then
  xsltproc --html --param datetime "\"$datetime\"" ${BASE_DIR}/disneyland_atr_wait_time.xslt $out 2>/dev/null > ${DS_OUT_DIR}/attr_wait_${file_datetime}.dat
fi

#========== DISNEYLAND DB INSERT ==========
syslog_info "Inserting Disneyland times into database"
$BASE_DIR/insert_wait_time_into_graphite.sh $DL_OUT_DIR/attr_wait_${file_datetime}.dat
if [ $? -ne 0 ]; then
  syslog_err "Error occured inserting data into database for file ${DL_OUT_DIR}/attr_wait_${file_datetime}.dat"
else
  rm -rf $DL_OUT_DIR/attr_wait_${file_datetime}.dat
  rm -rf $DL_OUT_DIR/attr_wait_${file_datetime}.htm
fi

#========== DISNEYSEA DB INSERT ==========
syslog_info "Inserting Disney Sea times into database"
$BASE_DIR/insert_wait_time_into_graphite.sh $DS_OUT_DIR/attr_wait_${file_datetime}.dat
if [ $? -ne 0 ]; then
  syslog_err "Error occured inserting data into database for file ${DS_OUT_DIR}/attr_wait_${file_datetime}.dat"
else
  rm -rf $DS_OUT_DIR/attr_wait_${file_datetime}.dat
  rm -rf $DS_OUT_DIR/attr_wait_${file_datetime}.htm
fi

syslog_info "Data load completed"

