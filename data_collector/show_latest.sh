#!/bin/bash

BASE_PATH=$( dirname $0 )
DB=$BASE_PATH/disney.sqlite

ROW1_COLOR=32
ROW2_COLOR=37

function _alternate_color_print {
  count=0
  while read line; do
    [ $((count%2)) -eq 1 ] && echo -en "\033[${ROW1_COLOR}m"
    [ $((count%2)) -eq 0 ] && echo -en "\033[${ROW2_COLOR}m"
    printf "%s\033[0m\n" "$line"
    count=$((count+1))
  done
}

function execute_sql_csv {
  echo $1 | sqlite3 -csv $DB | sed "s/\"//g"
}

echo "### TOKYO DISNEYLAND ###"
_sql='select max(datetime), attraction_name, wait from v_wait_time where park_name="東京ディズニーランド" group by attraction_name;'
if [[ "x$1" == "x--color" ]]; then
  execute_sql_csv "$_sql" | _alternate_color_print | sed "s/,,/,-,/g;s/,-,,/,-,-,/g" | column -s"," -t
else
  execute_sql_csv "$_sql" | sed "s/,,/,-,/g;s/,-,,/,-,-,/g" | column -s"," -t
fi

echo "### TOKYO DISNEYSEA ###"
_sql='select max(datetime), attraction_name, wait from v_wait_time where park_name="東京ディズニーシー" group by attraction_name;'
if [[ "x$1" == "x--color" ]]; then
  execute_sql_csv "$_sql" | _alternate_color_print | sed "s/,,/,-,/g;s/,-,,/,-,-,/g" | column -s"," -t
else
  execute_sql_csv "$_sql" | sed "s/,,/,-,/g;s/,-,,/,-,-,/g" | column -s"," -t
fi

