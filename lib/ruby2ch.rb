require "ruby2ch/version"

module Ruby2ch
  DEBUG = true

  require 'ruby2ch/ruby2ch_exception'
  require 'ruby2ch/board'
  require 'ruby2ch/dat'
  require 'ruby2ch/res'
  require 'ruby2ch/thre'
  require 'net/http'
  require 'pp' if DEBUG

  def self.root
    File.dirname __dir__
  end

  # HTTPでGETする
  # @param [URI] URL
  # @return [String] 取得本文
  def self.fetch(url)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    res.body.force_encoding("cp932").encode!('utf-8', :undef => :replace)
  end
end

#TODO: テストの用意。
#TODO: コメントを書いてメソッドを整える。