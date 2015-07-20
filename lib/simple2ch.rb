require "simple2ch/version"

module Simple2ch
  DEBUG = false

  require 'simple2ch/simple2ch_exception'
  require 'simple2ch/board'
  require 'simple2ch/dat'
  require 'simple2ch/res'
  require 'simple2ch/thre'
  require 'open-uri'
  require 'time'
  require 'charwidth'
  require 'retryable'
  require 'pp' if DEBUG

  def self.root
    File.dirname __dir__
  end

  # Module variables
  @@boards = {}

  # HTTPでGETする
  # @param [URI] url URL
  # @return [String] 取得本文
  def self.fetch(url)
    encode = if url.to_s.index('subject.txt') || url.to_s.index('SETTING.TXT') || url.to_s.index('.dat') || url.to_s.index('bbsmenu')
                    'SHIFT_JIS'
                  else
                    'UTF-8'
             end
    Retryable.retryable(tries: 5, on: [OpenURI::HTTPError], sleep: 3) do
      got_binary = OpenURI.open_uri(url, 'r:binary').read
      got_string = got_binary.force_encoding(encode).encode('utf-8', undef: :replace, invalid: :replace, replace: '〓')
    end
  end

  # bbsmenuのURLが渡されればセットして，板リストを返す
  # @param [String] bbsmenu_url bbs_menuのURL
  # @option [Boolean] force_refresh キャッシュを利用せず板リストを再取得する
  # @return [Array<Simple2ch::Board>] 板リスト
  def self.boards(bbsmenu_url=nil, force_refresh:nil)
    if bbsmenu_url
      bbsmenu_urls = {
        net: 'http://menu.2ch.net/bbsmenu.html', sc: 'http://2ch.sc/bbsmenu.html', open: 'http://open2ch.net/bbsmenu.html'
      }
      # http://www.rubular.com/r/u1TJbQAULD
      board_extract_regex = /<A HREF=http:\/\/(?<subdomain>\w+).(?<openflag>open|)2ch.(?<tld>sc|net)\/(?<board_name>\w+)\/>(?<board_name_ja>.+)<\/A>/
      type_of_2ch = self.type_of_2ch(bbsmenu_url)

      if force_refresh || (boards=@@boards.fetch(type_of_2ch, [])).size == 0
        prepared_bbsmenu_url = bbsmenu_urls[type_of_2ch]

        data = nil
        boards_array = []

        raise RuntimeError, "Failed to fetch #{url}" if (data = fetch(URI.parse(prepared_bbsmenu_url))).empty?
        raise RuntimeError, "Failed to parse #{url}" if (boards_array=data.scan(board_extract_regex).uniq).empty?

        boards_array.each do |b|
          boards << Simple2ch::Board.new(b[4],"http://#{b[0]}.#{b[1]}2ch.#{b[2]}/#{b[3]}/")
        end
        @@boards[type_of_2ch] = boards
      end
    end
    @@boards[type_of_2ch]
  end

  # 2chのタイプを返す
  # @param [String] url URL
  # @return [Symbol] :open or :net or :sc
  # @raise [NotA2chUrlException] 2chのURLでないURLが与えられた際に発生
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
      raise NotA2chUrlException, "Given URL: #{url}"
    end
  end

  # URLを分解する
  # @param [String] url URL
  # @return [Array<String>] 結果(thread_key等が該当無しの場合，nilを返す)
  # @raise [NotA2chUrlException] 2chのURLでないURLが与えられた際に発生
  def self.parse_url(url)
    # http://www.rubular.com/r/h63xdfmQIH
    case url.to_s
      when /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/test\/read.cgi\/(?<board_name>.+)\/(?<thread_key>[0-9]+)/,
          /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/(?<board_name>.+)\/subject\.txt/,
          /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch\.(?<tld>net|sc)\/(?<board_name>.+)\//,
          /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch\.(?<tld>net|sc)\/(?<board_name>\w+)/,
          /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/(.+)\/dat\/(?<thread_key>[0-9]+)\.dat/,
          /http:\/\/(?:(?<server_name>.*)\.)?(?:(?<openflag>open)?)2ch\.(?<tld>sc|net)/
        {server_name: ($~[:server_name] rescue nil),
         board_name: ($~[:board_name] rescue nil),
         openflag: ($~[:openflag] rescue nil),
         tld: $~[:tld],
         thread_key: ($~[:thread_key] rescue nil) }
      else
        raise NotA2chUrlException, "Given URL: #{url}"
    end
  end
end

