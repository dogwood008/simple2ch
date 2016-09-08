module Simple2ch
  class Dat
    # @return [String] スレッドキー
    attr_reader :thread_key
    # @return [String] タイトル
    attr_reader :title
    # @return [Bbs2chUrlValidator::UrlInfo] URL
    attr_reader :url

    # @param [Thre] thre スレッド
    def initialize(thre)
      @thre = thre
      @thread_key = thre.thread_key
      @data = nil
      @responses = nil
      @is_kako_log = nil
    end

    # Datを解析して、レスを返す
    # @return [Array<Res>] レス
    def responses
      parse_dat unless @responses
      @responses
    end

    # Datを解析して過去ログかどうかを返す
    # @return [Boolean] 過去ログか否か
    def kako_log?
      parse_dat if @is_kako_log.nil?
      @is_kako_log
    end

    # @return [Bbs2chUrlValidator::UrlInfo] dat URL
    def url
      Bbs2chUrlValidator::URL.parse(@thre.url.dat)
    end

    private

    # datファイルを取得する
    # @return [String] 取得したdatファイルの中身
    def fetch_dat
      @data ||= Simple2ch.fetch(url)
    end

    # datファイルを解析してResを作成する
    def parse_dat
      res_num = 0
      @responses = []
      @is_kako_log = false
      fetch_dat.each_line do |l|
        res_num += 1
        begin
          if res_num==1
            title = l.split('<>').pop
            @title = title unless @title
          end
          @responses << Res.parse(res_num, l)
        rescue KakoLogError
          @is_kako_log = true
        end
      end
    end
  end
end
