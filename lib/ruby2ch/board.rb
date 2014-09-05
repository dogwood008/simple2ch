class Board
  # @return [URI] 板のURL
  attr_reader :url
  # @return [String] 板の名前
  attr_reader :title


  # @param [String] tiitle 板の名前
  # @param [String] url 板のURL
  def initialize(title, url)
    @url = validate_url url
    @title = title
    @thres = []
  end

  # 板に属する全てのスレッドを返す
  # @return [Array<Thre>] 板に属する全てのスレッド
  def all_of_threads
    if @thres.size > 0
      @thres
    else
      fetch_all_thres
    end
  end

  private
  # URLが正しいかバリデーションする
  # @param [URI] url
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
    elsif url == DUMMY_URL
      board_url = DUMMY_URL
    else
      raise NotA2chUrlException
    end
  end

  # 板に属する全てのスレッドをsubject.txtから取得する
  # @return [Array<Thre>] 板に属する全てのスレッド
  def fetch_all_thres
    subject_url = @url+'subject.txt'

    subject_txt = Ruby2ch.fetch(subject_url)
    subject_txt.each_line do |line|
      @thres << Thre.new(self, line)
    end
    @thres
  end
end