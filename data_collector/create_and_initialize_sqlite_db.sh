#!/bin/bash

BASE_DIR=$( dirname $0 )
DB="${BASE_DIR}/disney.sqlite"

_temp_html=$( mktemp `basename $0`.XXXX )
_temp_out=$( mktemp `basename $0`.XXXX )

#-----------
# FUNCTIONS
#-----------

function cleanup {
	[ -e $_temp_out ] && rm -rf $_temp_out
	[ -e $_temp_html ] && rm -rf $_temp_html
}
trap cleanup EXIT

function execute_sql {
  #echo "DB: $1" 1>&2
  echo $1 | sqlite3 $2
  local _rc=$?
  if [ $_rc -ne 0 ]; then
    exit $_rc
  fi
}

function create_db_tables {
  execute_sql 'create table if not exists parks(id INTEGER PRIMARY KEY, name TEXT, abbr TEXT);' $1
  execute_sql 'create table if not exists attractions(id INTEGER PRIMARY KEY, park_id INTEGER REFERENCES parks(id), name TEXT);' $1
  execute_sql 'create table if not exists data(id INTEGER PRIMARY KEY, attraction_id INTEGER REFERENCES attractions(id), datetime INTEGER, wait INTEGER, status TEXT, fastpass TEXT);' $1
}

function create_db_indexes {
  execute_sql 'create unique index idx_date_attraction on data(datetime,attraction_id);' $1
}

#----------
# MAIN
#----------

echo "Deleting old DB..."
[ -e $DB ] && rm -rf $DB

echo "Creating DB tables..."
create_db_tables $DB

echo "Creating DB indexes..."
create_db_indexes $DB

echo "Adding park info..."
execute_sql 'insert into parks (name,abbr) values ("東京ディズニーランド","tdl");' $DB
execute_sql 'insert into parks (name,abbr) values ("東京ディズニーシー","tds");' $DB

echo "Getting attractions for TDL..."
curl -s -o $_temp_html -f  "http://s.tokyodisneyresort.jp/tdl/atrc_list.htm"
_attractions=$( xsltproc --html attraction_name_extract.xslt $_temp_html > $_temp_out 2>/dev/null )

echo "Adding attrations for TDL..."
_id=$( execute_sql 'select id from parks where abbr="tdl";' $DB )
while read attr; do
  execute_sql "insert into attractions(park_id, name) values (${_id},\"$attr\");" $DB
done < $_temp_out

echo "Getting attractions for TDS..."
curl -s -o $_temp_html -f  "http://s.tokyodisneyresort.jp/tds/atrc_list.htm"
_attractions=$( xsltproc --html attraction_name_extract.xslt $_temp_html > $_temp_out 2>/dev/null )

echo "Adding attrations for TDS..."
_id=$( execute_sql 'select id from parks where abbr="tds";' $DB )
while read attr; do
  execute_sql "insert into attractions(park_id, name) values (${_id},\"$attr\");" $DB
done < $_temp_out

echo "DONE"

