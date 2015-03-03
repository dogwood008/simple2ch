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
  require 'charwidth'
  require 'pp' if DEBUG

  def self.root
    File.dirname __dir__
  end

  # Module variables
  @@bbsmenu_url = ''
  @@boards = []

  # HTTPでGETする
  # @param [URI] url URL
  # @param [Symbol] site :net, :sc, :openのいずれか．(2ch.net or 2ch.sc or open2ch.net)
  # @return [String] 取得本文
  def self.fetch(url, site=:sc)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    case site
      when :net, :sc
        res.body.force_encoding("cp932").encode!('utf-8', :undef => :replace)
      when :open
        res.body.force_encoding("utf-8")
    end
  end

  # bbsmenuのURLが渡されればセットして，板リストを返す
  # @param [String] bbsmenu_url bbs_menuのURL
  # @param [Symbol] site :net, :sc, :openのいずれか．(2ch.net or 2ch.sc or open2ch.net)
  # @return [Array<Simple2ch::Board>] 板リスト
  def self.board_lists(bbsmenu_url=nil, site=nil)
    if bbsmenu_url
      @@bbsmenu_url = bbsmenu_url
      # http://www.rubular.com/r/u1TJbQAULD
      board_extract_regex = /<A HREF=http:\/\/(?<subdomain>\w+).(?<openflag>open|)2ch.(?<tld>sc|net)\/(?<board_name>\w+)\/>(?<board_name_ja>.+)<\/A>/

      data = nil
      boards_array = []
      raise RuntimeError, "Failed to fetch #{url}" if (data = fetch(URI.parse(@@bbsmenu_url), site)).empty?
      raise RuntimeError, "Failed to parse #{url}" if (boards_array=data.scan(board_extract_regex).uniq).empty?
    end

    @@boards = []
    boards_array.each do |b|
      @@boards << Simple2ch::Board.new(b[4],"http://#{b[0]}.#{b[1]}2ch.#{b[2]}/#{b[3]}/")
    end
    @@boards
  end
end

