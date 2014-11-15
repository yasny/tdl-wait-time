#!/bin/bash

BASE_DIR=$( dirname $0 )
DB="${BASE_DIR}/disney.sqlite"

_temp_html=$( mktemp `basename $0`.XXXX )
_temp_out=$( mktemp `basename $0`.XXXX )
_temp_fixed_html=$( mktemp `basename $0`.XXXX )

#-----------
# FUNCTIONS
#-----------

function cleanup {
	[ -f $_temp_out ] && rm -rf $_temp_out
	[ -f $_temp_html ] && rm -rf $_temp_html
	[ -f $_temp_fixed_html ] && rm -rf $_temp_fixed_html
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
  execute_sql 'create table if not exists lands(id INTEGER PRIMARY KEY, park_id INTEGER REFERENCES parks(id), name TEXT);' $1
  execute_sql 'create table if not exists attractions(id INTEGER PRIMARY KEY, land_id INTEGER REFERENCES land(id), name TEXT);' $1
  execute_sql 'create table if not exists data(id INTEGER PRIMARY KEY, attraction_id INTEGER REFERENCES attractions(id), datetime INTEGER, wait INTEGER, status TEXT, fastpass TEXT, update_time TEXT);' $1
}

function create_db_indexes {
  execute_sql 'create unique index idx_date_attraction on data(datetime,attraction_id);' $1
}

function create_db_views {
  execute_sql 'create view v_wait_time as select p.name as park_name,l.name as land_name,a.name as attraction_name,d.datetime,d.wait from data as d join attractions as a on d.attraction_id=a.id, lands as l on a.land_id=l.id, parks as p on l.park_id=p.id;' $1
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

echo "Creating DB views..."
create_db_views $DB

echo "Adding park info..."
execute_sql 'insert into parks (name,abbr) values ("東京ディズニーランド","tdl");' $DB
execute_sql 'insert into parks (name,abbr) values ("東京ディズニーシー","tds");' $DB

#---- DISNEY LAND ----

echo "Getting attractions for TDL..."
curl -s -o $_temp_html -f  "http://s.tokyodisneyresort.jp/tdl/atrc_list.htm"

#cat $_temp_html | sed 's/h2 class="themeName"><p>\(.*\)<\/p>/h2 class="themeName">\1/' > $_temp_fixed_html

cat $_temp_html | sed 's/h2 class="themeName"><p>\(.*\)<\/p>/h2 class="themeName">\1/' > $_temp_fixed_html
_attractions=$( xsltproc --html attraction_name_extract.xslt $_temp_fixed_html > $_temp_out 2>/dev/null )

echo "Adding lands for TDL..."
_id=$( execute_sql 'select id from parks where abbr="tdl";' $DB )
cat $_temp_out | cut -d"," -f1 | uniq | while read land; do
  execute_sql "insert into lands(park_id, name) values (${_id},\"$land\");" $DB
done

echo "Adding attrations for TDL..."
while read line; do
  _land=$( echo $line | cut -d"," -f1 )
  _attr=$( echo $line | cut -d"," -f2 )
  _id=$( execute_sql "select id from lands where name=\"${_land}\";" $DB )
  execute_sql "insert into attractions(land_id, name) values (${_id},\"${_attr}\");" $DB
done < $_temp_out

#---- DISNEY SEA ----

echo "Getting attractions for TDS..."
curl -s -o $_temp_html -f  "http://s.tokyodisneyresort.jp/tds/atrc_list.htm"
cat $_temp_html | sed 's/h2 class="themeName"><p>\(.*\)<\/p>/h2 class="themeName">\1/' > $_temp_fixed_html
_attractions=$( xsltproc --html attraction_name_extract.xslt $_temp_fixed_html > $_temp_out 2>/dev/null )

echo "Adding lands for TDS..."
_id=$( execute_sql 'select id from parks where abbr="tds";' $DB )
cat $_temp_out | cut -d"," -f1 | uniq | while read land; do
  execute_sql "insert into lands(park_id, name) values (${_id},\"$land\");" $DB
done

echo "Adding attrations for TDS..."
_id=$( execute_sql 'select id from parks where abbr="tds";' $DB )
while read line; do
  _land=$( echo $line | cut -d"," -f1 )
  _attr=$( echo $line | cut -d"," -f2 )
  _id=$( execute_sql "select id from lands where name=\"${_land}\";" $DB )
  execute_sql "insert into attractions(land_id, name) values (${_id},\"${_attr}\");" $DB
done < $_temp_out

echo "DONE"

