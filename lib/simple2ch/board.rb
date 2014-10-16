module Simple2ch
  class Board
    # @return [URI] 板のURL
    attr_reader :url
    # @return [String] 板のタイトル
    attr_reader :title
    # @return [String] サーバ名
    attr_reader :server_name
    # @return [String] 板の名前（コンピュータ名）
    attr_reader :board_name
    # @return [Boolean] おーぷん2chか否か
    attr_reader :open_flag


    # @param [String] title 板の名前
    # @param [String] url 板のURL
    def initialize(title, url)
      @server_name = @board_name = nil
      @url = validate_url url
      @title = title
      @thres = []
    end

    # 板に属する全てのスレッドを返す
    # @return [Array<Thre>] 板に属する全てのスレッド
    def thres
      if @thres.size > 0
        @thres
      else
        fetch_all_thres
      end
    end

    private
    # URLが正しいかバリデーションする
    # @param [URI] url
    # @raise [Simple2ch::NotA2chUrlException] 2chのフォーマットで無いURLを渡したときに発生
    # @raise [URI::InvalidURIError] そもそもURLのフォーマットで無いときに発生
    def validate_url(url)
      sp_uri = URI.parse url
      board_url = ''

      if sp_uri.host.index '2ch'
        case url
          when /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/test\/read.cgi\/(?<board_name>.+)\/(?<thread_key>[0-9]+)/,
              /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/(?<board_name>.+)\/subject\.txt/,
              /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch\.(?<tld>net|sc)\/(?<board_name>.+)\//,
              /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch\.(?<tld>net|sc)\/(?<board_name>\w+)/,
              /http:\/\/(?<server_name>.+)\.(?<openflag>open)?2ch.(?<tld>net|sc)\/(.+)\/dat\/(?<thread_key>[0-9]+)\.dat/
            @server_name = $~[:server_name]
            @board_name = $~[:board_name]
            @open_flag = ($~[:openflag] rescue false) && $~[:openflag]
            board_url = URI.parse("http://#{server_name}.#{open_flag ? 'open' : ''}2ch.#{open_flag ? 'net' : 'sc'}/#{board_name}/")
          else
            raise NotA2chUrlException, "Given URL :#{url}"
        end
      else
        raise NotA2chUrlException, "Given URL :#{url}"
      end
    end

    # 板に属する全てのスレッドをsubject.txtから取得する
    # @return [Array<Thre>] 板に属する全てのスレッド
    def fetch_all_thres
      subject_url = @url+'subject.txt'

      subject_txt = Simple2ch.fetch(subject_url)
      subject_txt.each_line do |line|
        @thres << Thre.parse(self, line)
      end
      @thres
    end
  end
end