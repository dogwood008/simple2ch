# Simple2ch
2ch Japanese BBS simple reader for Ruby.

Ruby用の2chの簡易リーダーです。

![gem version](https://badge.fury.io/rb/simple2ch.svg)
[リファレンス](http://www.rubydoc.info/gems/simple2ch/)

## 更新内容

## [v1.1.0]

* 全面的にメソッド数を見直し、大幅なリファクタリング
  * v0.X 系とは互換性一部なし
* クラス名変更： Res -> Response, Thre -> Thread

## [v0.1.9]

* 著者をプレインテキストで返すメソッドを追加

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

### Simple2ch:BBS

```ruby
bbs = Simple2ch::BBS(:sc)
bbs.boards #=> [#<Simple2ch::Board>, ...]
```

### Simple2ch::Board

```ruby
news_boards = bbs.boards.find_all { |b| b.title.include?('ニュース') } #=> [#<Simple2ch::Board>...]
news_board = news_boards.first
news_board.title #=> "ニュース速報α"
news_board.threads #=> [#<Simple2ch::Thread>, ...]
```

### Simple2ch::Thre

```ruby
thread = news_board.threads.first
thread.resonses #=> [#<Simple2ch::Response>, ...]
```

#### URLを直接指定して取得

```ruby
thread = Simple2ch::Thread.new('http://toro.open2ch.net/test/read.cgi/tech/1371956681/') #=> #<Simple2ch::Thre>
thread.title #=> "さぁRubyはじめるよ"
```

### Simple2ch::Res

```ruby
thread.responses #=> [#<Simple2ch::Response>, ...]
res = thread.responses[0] #=> #<Simple2ch::Response>
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

