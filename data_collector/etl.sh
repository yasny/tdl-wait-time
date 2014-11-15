#!/bin/bash

BASE_DIR=$( dirname $0 )

cd $BASE_DIR
./get_attr_wait_time.sh
./pivot_by_attr.sh
cp all.csv /var/www/html/disney/all_from_db.csv

