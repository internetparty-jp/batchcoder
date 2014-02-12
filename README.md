掲示板データ入力
----------------

必須環境
--------

- Ruby 2.0.0-p353
- bundlerをインストール済みであること

インストール方法
----------------

```
> git clone git@github.com:miminashi/batchcoder.git
> cd batchcoder
> bundle ins --path vendor/bundle
```

動かし方
--------

- 以下のコマンドを実行

```
> bundle ex ruby batch.rb -u "ユーザー名" -p "パスワード" -f "csvファイル名"
```

- カテゴリーを聞かれるので番号を入力してください！

LICENSE
-------

[MIT](http://opensource.org/licenses/MIT)
