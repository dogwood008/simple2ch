require "simple2ch/version"

module Simple2ch
  DEBUG = false

  require 'simple2ch/simple2ch_exception'
  require 'simple2ch/board'
  require 'simple2ch/dat'
  require 'simple2ch/res'
  require 'simple2ch/thre'
  require 'net/http'
  require 'time'
  require 'pp' if DEBUG

  def self.root
    File.dirname __dir__
  end

  # HTTPでGETする
  # @param [URI] url URL
  # @return [String] 取得本文
  def self.fetch(url)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    res.body.force_encoding("cp932").encode!('utf-8', :undef => :replace)
  end
end

