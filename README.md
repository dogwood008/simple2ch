# Simple2ch

2ch Japanese BBS simple reader.

## Installation

Add this line to your application's Gemfile:

    gem 'simple2ch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple2ch

## Usage
* 初期化
```ruby
require 'simple2ch'
```


* スレ取得
```ruby
board = Simple2ch::Board.new('ニュー速VIP', 'http://viper.2ch.sc/news4vip/')
board.thres #=>[#<Simple2ch::Thre>, ..., #<Simple2ch::Thre>]
```

* レス取得
```ruby
thre = board.thres[hoge] #=> #<Simple2ch::Thre>
thre.reses #=> [#<Simple2ch::Res>, ..., #<Simple2ch::Res>]
```

* 書き込み内容取得
```ruby
res = thre.reses[foo] #=> #<Simple2ch::Res>
res.author #=> "以下、＼(^o^)／でVIPがお送りします"
res.contents #=> "hoge foo bar"
```


## Contributing

1. Fork it ( https://github.com/dogwood008/simple2ch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
