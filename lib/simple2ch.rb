require 'simple2ch/version'
require 'singleton'

module Simple2ch
  class Simple2ch
    DEBUG = false

    require 'simple2ch/simple2ch_exception'
    require 'simple2ch/board'
    require 'simple2ch/dat'
    require 'simple2ch/res'
    require 'simple2ch/thre'
    require 'simple2ch/regex'
    require 'open-uri'
    require 'time'
    require 'charwidth'
    require 'retryable'
    require 'pp' if DEBUG

    def initialize(type_of_2ch)
      @boards = {}
      case type_of_2ch
        when :sc, :open
          @boards[type_of_2ch] = boards(type_of_2ch)
        else
          fail RuntimeError, %Q{Invalid "type_of_2ch" given: #{type_of_2ch} (:sc or :open is correct.)}
      end
    end

    def root
      File.dirname __dir__
    end

    # Module variables
    @boards = {}

    # HTTPでGETする
    # @param [URI] url URL
    # @return [String] 取得本文
    def fetch(url)
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
    # @param [Symbol] type_of_2ch :sc or :open
    # @option [Boolean] force_refresh キャッシュを利用せず板リストを再取得する
    # @return [Array<Simple2ch::Board>] 板リスト
    def boards(type_of_2ch, force_refresh:nil)
      fail RuntimeError, '"type_of_2ch" is nil.' unless type_of_2ch
      bbsmenu_urls = {
          sc: 'http://2ch.sc/bbsmenu.html', open: 'http://open2ch.net/bbsmenu.html'
      }

      if force_refresh || (!@boards.nil? && ((@boards.fetch(type_of_2ch, [])).size == 0))
        prepared_bbsmenu_url = bbsmenu_urls[type_of_2ch]

        fail RuntimeError, "Failed to fetch #{url}" if (data = fetch(URI.parse(prepared_bbsmenu_url))).empty?
        fail RuntimeError, "Failed to parse #{url}" if (scaned_data=data.scan(Regex::BOARD_EXTRACT_REGEX).uniq).empty?

        boards = scaned_data.map do |b|
          Simple2ch::Board.new(b[4],"http://#{b[0]}.#{b[1]}2ch.#{b[2]}/#{b[3]}/")
        end
      else
        @boards[type_of_2ch]
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
  end

  # URLを分解する
  # @param [String] url URL
  # @return [Array<String>] 結果(thread_key等が該当無しの場合，nilを返す)
  # @raise [NotA2chUrlException] 2chのURLでないURLが与えられた際に発生
  def parse_url(url)
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

