#!/bin/bash

BASE_DIR=$( dirname $0 )
TDL_DIR="$BASE_DIR/tdl"
TDS_DIR="$BASE_DIR/tds"

OUTPUT_CSV="$BASE_DIR/all.csv"

echo "date,attr,wait" > $OUTPUT_CSV
grep -h "ジャングル" $TDL_DIR/*.dat | cut -d"," -f1,2,5 >> $OUTPUT_CSV
grep -h "スペース" $TDL_DIR/*.dat |cut -d"," -f1,2,5 >> $OUTPUT_CSV
grep -h "スプラッシュ" $TDL_DIR/*.dat |cut -d"," -f1,2,5 >> $OUTPUT_CSV
grep -h "ツアーズ" $TDL_DIR/*.dat |cut -d"," -f1,2,5 >> $OUTPUT_CSV
grep -h "ホーンテッド" $TDL_DIR/*.dat |cut -d"," -f1,2,5 >> $OUTPUT_CSV
grep -h "プーさん" $TDL_DIR/*.dat |cut -d"," -f1,2,5 >> $OUTPUT_CSV

grep -h "インディ" $TDS_DIR/*.dat |cut -d"," -f1,2,5 >> $OUTPUT_CSV
grep -h "タワー" $TDS_DIR/*.dat |cut -d"," -f1,2,5 >> $OUTPUT_CSV
grep -h "レイジング" $TDS_DIR/*.dat | cut -d"," -f1,2,5 >> $OUTPUT_CSV


