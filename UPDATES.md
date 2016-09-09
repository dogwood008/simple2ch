## [v1.1.0]

* 全面的にメソッド数を見直し、大幅なリファクタリング
  * v0.X 系とは互換性一部なし
* クラス名変更： Res -> Response, Thre -> Thread

## [v0.1.9]

* 著者をプレインテキストで帰すメソッドを追加

## [v0.1.8]

* 機能追加
  * URLからスレを取得した時に，subject.txtに当該スレが無い場合，タイトルをdatの解析結果から取得するよう変更
  
## [v0.1.7]

* 機能追加
  * Thre#url, Thre#dat_urlの追加
* バグ修正
  * エンコーディング関連

## [v0.1.6]

* 機能追加
  * 板一覧の取得に対応
  * URLからスレの取得に対応


## [v0.1.5]

* デバッグ
  * StandardErrorで例外を捕縛できない問題を修正
* 機能追加
  * おーぷん２ちゃんねる対応

## [v0.1.4]

* デバッグ
  * Thre#resesを実行した際に、IDを持たないレスがあれば、DatParseExceptionが起きる問題を修正
* エイリアス追加
  * Thre#resをThre#resesのエイリアスに設定

## [v0.1.3]

* デバッグ
  * Res#received_anchors呼び出し時にNoThreGivenExceptionが起きる場合がある問題を修正

## [v0.1.2]

* リファクタリングとデバッグ
* メソッド修正
  * Thre#reses(Array<Fixnum>)で指定したレス番号のレスを取得
  * Thre#resesは今まで通り使用可能
* メソッド追加
  * Thre#received_anchors
    * 全レスについて被レスを返す
  * Res#received_anchors(Thre)
    * 自レスへの被レスを返す

## [v0.1.1]

* メソッド追加
  * Res#anchorsの追加
    * レス中のアンカーを抽出する
* 必要gemの追加
  * Charwidthを追加

## [v0.1.0]

* メソッド名の変更
  * Thre.new から Thre.parse に変更
  * Thre.newは引数の数を変更
  * この変更に伴い、v0.0.2以下とは一部互換性無し
* バグ修正
  * Time.parseの呼び出しに失敗する問題を修正
  * その他
* その他微細な修正

## [v0.0.2]

* メソッド名の変更
  * Board#threads から Board#thres に変更
* ドキュメントの再生成
  * モジュール名が誤っていたため
* README.mdを修正
  * 使用法などを追加
  * yardの結果を追加

## [v0.0.1]

* 初版
