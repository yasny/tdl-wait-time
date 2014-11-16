東京ディズニーランド・ディズニーシーの待ち時間グラフ
=============

東京ディズニーランドとディズニーシーの乗り物待ち時間を取得して、グラフするプロジェクト。

![スクリーンショット](sample/tdl_wait_time_sample.png)

## 仕組み ##

### データ収集 ###

`data_collector`はデータ収集ツール。[ディズニーランド](http://s.tokyodisneyresort.jp/tdl/atrc_list.htm])と[ディズニーシー](http://s.tokyodisneyresort.jp/tds/atrc_list.htm)の待ち時間ウェブサイトをダウンロードして、XSLTを利用して中間フォーマットに変換してから、sqliteデータベースにデータを保存する。

`etl.sh`をcronで登録して、定期的にデータを収集することが可能。

### サイト ###

`site`は、[CherryPy](http://www.cherrypy.org/)で作った簡単なウェブサイトである。[rickshaw.js](https://github.com/shutterstock/rickshaw)を利用して、CSVデータをグラフ化する。

グラフ作成は、[Multiseries Line Chart using Rickshaw toolkit](https://gist.github.com/clebio/4420982)を参照しながら作った。
