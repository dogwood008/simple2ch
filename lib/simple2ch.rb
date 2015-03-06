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
      else
        raise RuntimeError, "Invalid type of 2ch was given: #{site}"
    end
  end

  # bbsmenuのURLが渡されればセットして，板リストを返す
  # @param [String] bbsmenu_url bbs_menuのURL
  # @return [Array<Simple2ch::Board>] 板リスト
  def self.boards(bbsmenu_url=nil)
    if bbsmenu_url
      bbsmenu_urls = {
        net: 'http://menu.2ch.net/bbsmenu.html', sc: 'http://2ch.sc/bbsmenu.html', open: 'http://open2ch.net/menu/pc_menu.html'
      }
      # http://www.rubular.com/r/u1TJbQAULD
      board_extract_regex = /<A HREF=http:\/\/(?<subdomain>\w+).(?<openflag>open|)2ch.(?<tld>sc|net)\/(?<board_name>\w+)\/>(?<board_name_ja>.+)<\/A>/
      type_of_2ch = self.type_of_2ch(bbsmenu_url)
      @@bbsmenu_url = bbsmenu_urls[type_of_2ch]

      data = nil
      boards_array = []

      raise RuntimeError, "Failed to fetch #{url}" if (data = fetch(URI.parse(@@bbsmenu_url), type_of_2ch)).empty?
      raise RuntimeError, "Failed to parse #{url}" if (boards_array=data.scan(board_extract_regex).uniq).empty?
    end

    @@boards = []
    boards_array.each do |b|
      @@boards << Simple2ch::Board.new(b[4],"http://#{b[0]}.#{b[1]}2ch.#{b[2]}/#{b[3]}/")
    end
    @@boards
  end

  # 2chのタイプを返す
  # @param [String] url URL
  # @return [Symbol] :open or :net or :sc
  def self.type_of_2ch(url)
    parsed_url = self.parse_url(url)
    openflag = parsed_url[:openflag]
    tld = parsed_url[:tld]
    if openflag && tld=='net'
      :open
    elsif !openflag && tld=='net'
      :net
    elsif !openflag && tld=='sc'
      :sc
    else
      nil
    end
  end

  # URLを分解する
  # @param [String] url URL
  # @return [Array<String>] 結果(thread_key等が該当無しの場合，nilを返す)
  # @raise [NotA2chUrlException] 2chのURLでないURLが与えられた際に発生
  def self.parse_url(url)
    case url
      when /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/test\/read.cgi\/(?<board_name>.+)\/(?<thread_key>[0-9]+)/,
          /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/(?<board_name>.+)\/subject\.txt/,
          /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch\.(?<tld>net|sc)\/(?<board_name>.+)\//,
          /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch\.(?<tld>net|sc)\/(?<board_name>\w+)/,
          /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/(.+)\/dat\/(?<thread_key>[0-9]+)\.dat/
        { server_name: $~[:server_name],
          board_name: $~[:board_name],
          openflag: ($~[:openflag] rescue nil),
          tld: $~[:tld],
          thread_key: ($~[:thread_key] rescue nil)
        }
      else
        raise NotA2chUrlException, "Given URL :#{url}"
    end
  end
end

