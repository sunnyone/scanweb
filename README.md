ScanWeb - Web UI for Scanner
===================================

What's this?
-------------
ScanWebは、Webブラウザからスキャン指示を行うためのWebアプリケーションです。
scanimageコマンドのフロントエンドになっています。

環境
-----
* saneが動作するUnix互換環境(scanimageコマンドを利用)
* ImageMagick(convertコマンドを利用)
* Ruby 1.8.x
  * sinatra  (libsinatra-ruby1.8)
  * rubyzip  (libzip-ruby1.8)

使い方
---------
$ ruby scanweb.rb

これでWebサーバが起動するので、
  http://your-ip:10080/
にアクセスしてください。

スキャンの出力先は、scanweb.rbのOUTPUT_DIRにあります。
その他パラメータなどはハードコードされているので、適宜書き換えてご利用ください。

デーモン化するような仕組みは入っていませんので、常駐したい場合は他とうまく
組み合わせてください。私はrunitを利用しています。
  http://smarden.org/runit/

* 注意事項
インターネットに公開することを目的として作成されていません。信頼できるネットワーク上でご利用ください。
万が一、Webに公開したい場合、ApacheなどのWebサーバで認証をかけ、個人専用として、利用してください。
