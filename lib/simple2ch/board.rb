module Simple2ch
  class Board
    # @return [Bbs2chUrlValidator::URL] 板のURL
    attr_reader :url
    # @return [String] 板のタイトル
    attr_reader :title
    # @return [Time] 板オブジェクト更新日時
    attr_reader :updated_at


    # @param [String] title 板の名前
    # @param [String] url 板のURL
    # @option [Boolean] fetch_title 板の名前を自動取得するか
    def initialize(url, title: nil)
      @url = validate_url(url)
      @title = title
      @updated_at = Time.now
    end

    # 板に属する全てのスレッドを返す
    # @return [Array<Thre>] 板に属する全てのスレッド
    def threads
      @threads ||= fetch_all_threads
    end

    def ==(other)
      @url.to_s == other.url.to_s
    end

    private

    def validate_url(url)
      parsed = if url.instance_of?(Bbs2chUrlValidator::UrlInfo)
                 url
               else
                 Bbs2chUrlValidator::URL.parse(url)
               end
      return parsed if parsed && !parsed.board_name.empty?
      raise NotA2chBoardUrlError
    end

    # 板に属する全てのスレッドをsubject.txtから取得する
    # @return [Array<Thre>] 板に属する全てのスレッド
    def fetch_all_threads
      subject_url = @url.subject

      subject_txt = Simple2ch.fetch(subject_url)
      @threads = []
      subject_txt.each_line do |line|
        @threads << Simple2ch::Thread.parse(@url, line)
      end
      @updated_at = Time.now
      @threads
    end
  end
end
