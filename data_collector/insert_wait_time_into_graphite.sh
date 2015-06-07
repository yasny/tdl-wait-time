#!/bin/bash

GRAPHITE_HOST="127.0.0.1"
GRAPHITE_PORT=12003

function convert_ts_to_seconds {
  local _ts=$1
  local _os=$( uname -s )
  case "$_os" in
    "Darwin")
      local _sec=$( date -j -f "%Y-%m-%d %H:%M" "$_ts" +"%s" )
      ;;
    "Linux")
      local _sec=$( date -d "$_ts" +"%s" )
      ;;
    *)
      echo "Unknown OS, unable to convert timestamp." >&2
      exit 1
      ;;
  esac
  echo $_sec
}

function graphite_insert {
  local _schema=$1
  local _ts=$2
  local _wait=$3
  local _sec=$( convert_ts_to_seconds "$_ts" )
  #echo $_schema $_wait $_sec | nc -n $GRAPHITE_HOST $GRAPHITE_PORT
  echo $_schema $_wait $_sec
  local _rc=$?
  if [ $_rc -ne 0 ]; then
    echo "Unable to send data to Graphite. Is carbon-cache running?" >&2
    exit 1
  fi
}

if [ -z "$1" ]; then
  echo "$( basename $0 ) data_file"
  exit 1
fi

while read line; do
  if [[ $line == @* ]]; then
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

  _schema=""
  case "$_n" in
    # ---- DISNEY LAND ----
    "カリブの海賊")
      _schema="disney_land.adventure_land.pirates_of_the_caribbean"
      ;;
    "ジャングルクルーズ：ワイルドライフ・エクスペディション")
      _schema="disney_land.adventure_land.jungle_cruise"
      ;;
    "ビッグサンダー・マウンテン")
      _schema="disney_land.western_land.big_thunder_mountain"
      ;;
    "ホーンテッドマンション")
      _schema="disney_land.fantasy_land.haunted_mansion"
      ;;
    "スター・ツアーズ：ザ・アドベンチャーズ・コンティニュー")
      _schema="disney_land.tomorrow_land.star_tours"
      ;;
    "イッツ・ア・スモールワールド")
      _schema="disney_land.fantasy_land.its_a_small_world"
      ;;
    "プーさんのハニーハント")
      _schema="disney_land.fantasy_land.winnie_the_pooh"
      ;;
    "スプラッシュ・マウンテン")
      _schema="disney_land.critter_country.splash_mountain"
      ;;
    "スペース・マウンテン")
      _schema="disney_land.tomorrow_land.space_mountain"
      ;;
    "バズ・ライトイヤーのアストロブラスター")
      _schema="disney_land.tomorrow_land.buzz_lightyear"
      ;;
    'モンスターズ・インク“ライド＆ゴーシーク！”')
      _schema="disney_land.tomorrow_land.monsters_inc"
      ;;
    # ---- DISNEY SEA ----
    "タワー・オブ・テラー")
      _schema="disney_sea.american_waterfront.tower_of_terror"
      ;;
    "トイ・ストーリー・マニア！")
      _schema="disney_sea.american_waterfront.toy_story_mania"
      ;;
    "ストームライダー")
      _schema="disney_sea.port_discovery.storm_rider"
      ;;
    "アクアトピア")
      _schema="disney_sea.port_discovery.aquatopia"
      ;;
    "センター・オブ・ジ・アース")
      _schema="disney_sea.mysterious_island.center_of_the_earth"
      ;;
    "インディ・ジョーンズ・アドベンチャー：クリスタルスカルの魔宮")
      _schema="disney_sea.lost_river_delta.indiana_jones"
      ;;
    "レイジングスピリッツ")
      _schema="disney_sea.lost_river_delta.raging_spirits"
      ;;
    *)
      echo "UNKNOWN: $_n" >&2
      continue
      ;;
  esac

  graphite_insert $_schema "$_d" $_w

done < $1

