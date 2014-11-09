東京ディズニーランド・ディズニーシーの待ち時間グラフ
=============

東京ディズニーランドとディズニーシーの乗り物待ち時間を取得して、グラフするプロジェクト。

![スクリーンショット](sample/tdl_wait_time_sample.png)

## 仕組み ##

### データ収集 ###

`data_collector`はデータ収集ツール。[ディズニーランド](http://s.tokyodisneyresort.jp/tdl/atrc_list.htm])と[ディズニーシー](http://s.tokyodisneyresort.jp/tds/atrc_list.htm)の待ち時間ウェブサイトをダウンロードして、XSLTでCSV形式に変換する。

`get_attr_wait_time.sh`をcronで登録して、定期的にデータを収集することが可能。

### サイト ###

`www`は、[rickshaw.js](https://github.com/shutterstock/rickshaw)を利用して、CSVデータをグラフ化する。

グラフ作成は、[Multiseries Line Chart using Rickshaw toolkit](https://gist.github.com/clebio/4420982)を参照しながら作った。
