#!/bin/bash

BASE_PATH=$( dirname $0 )
DB="${BASE_PATH}/disney.sqlite"

function execute_sql {
  echo $1 | sqlite3 $2
  local _rc=$?
  if [ $_rc -ne 0 ]; then
    exit $_rc
  fi
}

if [ -z "$1" ]; then
  echo `basename $0` csv_file
  exit 1
fi

while read line; do
  #echo $line 1>&2
  if [[ $line == @* ]]; then
    _land_id=$( execute_sql "select id from lands where name=\"${line:1}\";" $DB )
    continue
  fi

  _d=$( echo $line | cut -d"," -f1 )
  _n=$( echo $line | cut -d"," -f2 )
  _s=$( echo $line | cut -d"," -f3 )
  _f=$( echo $line | cut -d"," -f4 )
  _w=$( echo $line | cut -d"," -f5 )
  _u=$( echo $line | cut -d"," -f6 )

  if [ -z "$_w" ]; then
    _w=0
  fi

  _id=$( execute_sql "select id from attractions where name=\"$_n\" and land_id=$_land_id;" $DB )
  if [ -z "$_id" ]; then
    echo "No ID for $_n"
    continue
  fi

  execute_sql "insert into data (datetime,attraction_id,wait,status,fastpass,update_time) values (datetime(\"$_d\"),$_id,$_w,\"$_s\",\"$_f\",time(\"$_u\"));" $DB
  #echo "insert into data (datetime,attraction_id,wait,status,fastpass,update_time) values (datetime(\"$_d\"),$_id,$_w,\"$_s\",\"$_f\",time(\"$_u\"));"
done < $1

