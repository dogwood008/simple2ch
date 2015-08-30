require 'simple2ch/version'
require 'singleton'

module Simple2ch
  require 'simple2ch/simple2ch_exception'
  require 'simple2ch/board'
  require 'simple2ch/dat'
  require 'simple2ch/res'
  require 'simple2ch/thre'
  require 'simple2ch/regex'
  require 'socket'
  require 'open-uri'
  require 'time'
  require 'charwidth'
  require 'retryable'

  @@bbs = {}

  class BBS
    attr_reader :type_of_2ch, :boards, :updated_at
    # class variables
    @boards = {}

    def initialize(type_of_2ch)
      @boards = {}
      case type_of_2ch
        when :sc, :open
          @type_of_2ch = type_of_2ch
          @boards = get_boards_by_type_of_2ch @type_of_2ch
        else
          fail RuntimeError, %Q{Invalid "type_of_2ch" given: #{type_of_2ch} (:sc or :open is correct.)}
      end
      @@bbs[type_of_2ch] = self
      @updated_at = Time.now
    end

    def root
      File.dirname __dir__
    end

    # titleに合致する板を取得する
    # @param [String] title タイトル
    # @return [Board] タイトルが合致した板 or nil
    def find(title)
      boards.find { |b| b.title==title }
    end

    # titleを含むする板を取得する
    # @param [String] title タイトル
    # @return [Board] タイトルが含まれるた板 or nil
    alias_method :[], :find

    # titleが含まれる板を取得する
    # @param [String] title タイトル
    # @return [Board] タイトルが含まれる板
    def contain(title)
      boards.find { |b| b.title.index title }
    end

    # titleに合致する板を全て取得する
    # @param [String] title タイトル
    # @return [Array<Board>] タイトルが合致した板の配列
    def contain_all(title)
      boards.find_all { |b| b.title.index title }
    end

    # bbsmenuのURLが渡されればセットして，板リストを返す
    # @param [Symbol] type_of_2ch :sc or :open
    # @option [Boolean] force_reload キャッシュを利用せず板リストを再取得する
    # @return [Array<Simple2ch::Board>] 板リスト
    def get_boards_by_type_of_2ch(type_of_2ch, force_reload: nil)
      if force_reload || @@bbs.fetch(type_of_2ch, nil).nil?
        fail RuntimeError, '"type_of_2ch" is nil.' unless type_of_2ch
        bbsmenu_urls = {
            sc: 'http://2ch.sc/bbsmenu.html', open: 'http://open2ch.net/bbsmenu.html'
        }

        prepared_bbsmenu_url = bbsmenu_urls[type_of_2ch]

        fail RuntimeError, "Failed to fetch #{url}" if (data = fetch(URI.parse(prepared_bbsmenu_url))).empty?
        fail RuntimeError, "Failed to parse #{url}" if (scaned_data=data.scan(Regex::BOARD_EXTRACT_REGEX).uniq).empty?

        scaned_data.map { |b|
          Simple2ch::Board.new(b[4], "http://#{b[0]}.#{b[1]}2ch.#{b[2]}/#{b[3]}/") rescue nil
        }.compact
      else
        @@bbs[type_of_2ch].boards
      end
    end
  end

  # HTTPでGETする
  # @param [URI] url URL
  # @return [String] 取得本文
  def fetch(url, encode=nil)
    unless encode
      encode = if url.to_s.index('subject.txt') || url.to_s.index('SETTING.TXT') || url.to_s.index('.dat') || url.to_s.index('bbsmenu')
                 'SHIFT_JIS'
               else
                 'UTF-8'
               end
    end
    Retryable.retryable(tries: 5, on: [OpenURI::HTTPError, SocketError], sleep: 3) do
      got_binary = OpenURI.open_uri(url, 'r:binary').read
      got_string = got_binary.force_encoding(encode).encode('utf-8', undef: :replace, invalid: :replace, replace: '〓')
    end
  end

  # 2chのタイプを返す
  # @param [String] url URL
  # @return [Symbol] :open or :net or :sc
  # @raise [NotA2chUrlException] 2chのURLでないURLが与えられた際に発生
  def type_of_2ch(url)
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
  def parse_url(url)
    # http://www.rubular.com/r/cQbzwkui6C
    # http://www.rubular.com/r/TYNlRzmmWz
    # http://www.rubular.com/r/h63xdfmQIH
    uri = URI.parse url
    [/^http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/test\/read\.cgi\/(?<board_name>.+)\/(?<thread_key>\d{10})\/?$/,
     /^http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/(?<board_name>(\w|)+)\/?$/,
     /^http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/(?<board_name>.+)\/subject\.txt$/,
     /^http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch\.(?<tld>net|sc)\/(?<board_name>.+)\/$/,
     /^http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch\.(?<tld>net|sc)\/(?<board_name>\w+)$/,
     /^http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/(.+)\/dat\/(?<thread_key>[0-9]+)\.dat$/,
     /^http:\/\/(?:(?<server_name>.*)\.)?(?:(?<openflag>open)?)2ch\.(?<tld>sc|net)$/].each do |r|
      if h = uri.to_s.match(r) { |hash|
              { server_name: (hash[:server_name] rescue nil),
                board_name: (hash[:board_name] rescue nil),
                openflag: (hash[:openflag] rescue nil),
                tld: (hash[:tld] rescue nil),
                thread_key: (hash[:thread_key] rescue nil) }
      }
        return h
      end
    end
    raise NotA2chUrlException, "Given URL: #{url}"
  end

  def self.parse_and_generate_url(url, type)
    parsed_url = parse_url url
    generate_url parsed_url, type
  end
  def self.generate_url(elements, type)
    # bbs:     http://www.2ch.sc/, http://open2ch.net/
    # board:   http://viper.2ch.sc/news4vip/, http://viper.open2ch.net/news4vip/
    # dat:     http://viper.2ch.sc/news4vip/dat/9990000001.dat, http://viper.open2ch.net/news4vip/dat/1439127670.dat
    # subject: http://viper.2ch.sc/news4vip/subject.txt, http://viper.open2ch.net/news4vip/subject.txt
    # setting: http://viper.2ch.sc/news4vip/SETTING.TXT, http://viper.open2ch.net/news4vip/SETTING.TXT
    # thread:  http://viper.2ch.sc/test/read.cgi/news4vip/9990000001/, http://viper.open2ch.net/test/read.cgi/news4vip/1439127670

    generated_url = "http://"
    if [:bbs, :board, :dat, :subject, :setting, :thread].index(type)
      generated_url << (elements[:server_name] ? "#{elements[:server_name]}." : '')
      generated_url << "#{elements[:openflag]}2ch.#{elements[:tld]}/"
    end

    if [:board, :dat, :setting].index(type)
      generated_url << "#{elements[:board_name]}/"
    end
    if type == :thread
      #generated_url << "test/read.cgi/#{elements[:board_name]}/#{elements[:thread_key]}/"
    end
    if type == :dat
      generated_url << "dat/#{elements[:thread_key]}.dat"
    end
    if type == :subject
      generated_url #TODO:
    end
    if [:thread].index(type)
      if elements[:thread_key] && !elements[:thread_key].empty?
        generated_url << 'test/read.cgi/'
      else
        fail "Thread key is empty: #{url}"
      end
    end
    if [:thread, :subject, :setting].index(type)
      if elements[:board_name] && !elements[:board_name].empty?
        case type
          when :thread
            generated_url << elements[:board_name] << '/'
          when :setting
            generated_url << 'SETTING.TXT'
        end
      else
        fail "Board name is empty: #{url}"
      end
    end
    if [:thread].index(type)
       generated_url << elements[:thread_key] << '/'
    end
    generated_url
  end

  def normalized_url(url, option=nil)
    hash = parse_url url
    type = if hash[:thread_key]
             :thread
           elsif :setting_txt
             :setting
           else
             :board
           end
    #warn 'Deprecated method Simple2ch#normalized_url called.'
    return self.parse_and_generate_url(url, type)

    hash = parse_url url
    url = "http://#{hash[:server_name]}.#{hash[:openflag] ? 'open' : ''}2ch.#{hash[:tld]}/"
    url << "#{hash[:board_name]}/" if hash[:board_name]
    if option==:setting_txt
      url << 'SETTING.TXT'
    else
      url << "#{hash[:thread_key]}/" if hash[:thread_key]
    end
    url
  end

  def <<(board)
    size = { before: @boards.size,
             after: @boards.delete_if { |b| b==board }.size }
    @boards << board

    if size[:before] - size[:after] > 0
      bbs = @@bbs.fetch(@type_of_2ch, Simple2ch::BBS.new(@type_of_2ch))
      bbs.boards.replace @boards
    end
  end
end

