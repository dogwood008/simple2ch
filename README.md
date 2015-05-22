# Simple2ch
2ch Japanese BBS simple reader for Ruby.

Ruby用の2chの簡易リーダーです。

![gem version](https://badge.fury.io/rb/simple2ch.svg)
[リファレンス](http://dogwood008.github.io/simple2ch/)

## 更新内容

## [v0.1.9]

* 著者をプレインテキストで帰すメソッドを追加

## [v0.1.8]

* 機能追加
  * URLからスレを取得した時に，subject.txtに当該スレが無い場合，タイトルをdatの解析結果から取得するよう変更

## Installation

Add this line to your application's Gemfile:

    gem 'simple2ch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple2ch

## Usage
### 初期化

```ruby
require 'simple2ch'
```

### Simple2ch

```ruby
boards = Simple2ch.boards 'http://open2ch.net' #=> [#<Simple2ch::Board>, ..., #<Simple2ch::Board>]
```

### Simple2ch::Board
```ruby
board = boards.find{|b| b.title == 'プログラム'} #=> #<Simple2ch::Board>
board.title #=> "プログラム"
board.thres #=> [#<Simple2ch::Thre>, ..., #<Simple2ch::Thre>]
```

### Simple2ch::Thre

```ruby
thre = board.thres.find{|t| t.title == 'さぁRubyはじめるよ'} #=> #<Simple2ch::Thre>
reses = thre.reses #=> [#<Simple2ch::Res>, ..., #<Simple2ch::Res>]
```

#### URLを直接指定して取得

```ruby
thre = Simple2ch::Thre.create_from_url('http://toro.open2ch.net/test/read.cgi/tech/1371956681/l50') #=> #<Simple2ch::Thre>
thre.title #=> "さぁRubyはじめるよ"
reses = thre.reses
```

#### 板を指定して取得

```ruby
board = Simple2ch::Board.new('ニュー速VIP', 'http://viper.open2ch.net/news4vip/')
thres = board.thres #=>[#<Simple2ch::Thre>, ..., #<Simple2ch::Thre>]
thre = thres.find{|t| t.title == 'プログラム'}
reses = thre.reses
```


### Simple2ch::Res

```ruby
res = reses[0] #=> #<Simple2ch::Res>
res.res_num #=> 1
res.contents #=> "Ruby覚えたいなぁ"
res.author #=> "s"
res.author_id #=> "R/Yck7smD"
res.date #=> 2013-06-23 12:04:41 +0900
res.mail #=> ""
```


## Contributing

1. Fork it ( https://github.com/dogwood008/simple2ch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

