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
          when /http:\/\/(.+)\.2ch.(net|sc)\/test\/read.cgi\/(.+)\/([0-9]+)/,
              /http:\/\/(.+)\.2ch\.(net|sc)\/(.+)\/subject\.txt/,
              /http:\/\/(.+)\.2ch\.(net|sc)\/(.+)\//,
              /http:\/\/(.+)\.2ch\.(net|sc)\/(\w+)/,
              /http:\/\/(.+)\.2ch.(net|sc)\/(.+)\/dat\/([0-9]+)\.dat/
            @server_name = $1; @board_name = $3
            board_url = URI.parse("http://#{$1}.2ch.sc/#{$3}/")
          else
            raise NotA2chUrlException
        end
      else
        raise NotA2chUrlException
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