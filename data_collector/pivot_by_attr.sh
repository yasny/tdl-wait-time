#!/bin/bash

BASE_DIR=$( dirname $0 )
TDL_DIR="$BASE_DIR/tdl"
TDS_DIR="$BASE_DIR/tds"
DB="$BASE_DIR/disney.sqlite"

OUTPUT_CSV="$BASE_DIR/all.csv"

function execute_sql_csv {
  echo $1 | sqlite3 -csv $DB
}

function get_data_for_attr {
  execute_sql_csv "select d.datetime,a.name,d.wait from data as d join attractions as a on d.attraction_id=a.id where a.name=\"$1\" and datetime > date(\"now\",\"-7 days\") order by d.datetime;"
}

echo "date,attr,wait" > $OUTPUT_CSV
get_data_for_attr "ジャングルクルーズ：ワイルドライフ・エクスペディション" >> $OUTPUT_CSV
get_data_for_attr "スペース・マウンテン" >> $OUTPUT_CSV
get_data_for_attr "スプラッシュ・マウンテン" >> $OUTPUT_CSV
get_data_for_attr "スター・ツアーズ：ザ・アドベンチャーズ・コンティニュー" >> $OUTPUT_CSV
get_data_for_attr "ホーンテッドマンション" >> $OUTPUT_CSV
get_data_for_attr "プーさんのハニーハント" >> $OUTPUT_CSV

get_data_for_attr "インディ・ジョーンズ（R）・アドベンチャー：クリスタルスカルの魔宮" >> $OUTPUT_CSV
get_data_for_attr "タワー・オブ・テラー" >> $OUTPUT_CSV

