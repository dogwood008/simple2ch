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
    # @return [Time] 板オブジェクト更新日時
    attr_reader :updated_at


    # @param [String] title 板の名前
    # @param [String] url 板のURL
    # @option [Boolean] fetch_title 板の名前を自動取得するか
    def initialize(title, url, fetch_title: nil)
      @server_name = @board_name = nil
      @url = validate_url(url)
      @title = if fetch_title || title.nil? || title.empty?
                 bbs.boards.find { |b| b.url==@url }.title
               else
                 title
               end
      @thres = []
      @updated_at = Time.now
    end

    # 板に属する全てのスレッドを返す
    # @return [Array<Thre>] 板に属する全てのスレッド
    def threads
      if @thres.size > 0
        @thres
      else
        fetch_all_thres
      end
    end

    def thres
      warn "[Deprecated] Board#thres was called: #{caller_locations(1).first.label}"
      threads
    end

    # Simple2ch::BBSオブジェクトを返す
    # @return [BBS]
    def bbs
      @bbs ||= Simple2ch::BBS.new(type_of_2ch)
      @bbs << self
      @bbs
      #fail 'Please implement me. Simple2ch::Board#bbs'
    end

    # おーぷん2chか否かを返す
    # @return [Boolean] おーぷん2chか否か
    def open2ch?
      @f_open2ch && true
    end

    # 2chタイプ名の取得
    # @return [Symbol] 2chタイプ名(:net, :sc, :open)
    def type_of_2ch
      Simple2ch.type_of_2ch(@url.to_s)
    end

    # SETTING.TXTの情報を取得する
    def setting(param)
      unless @setting_txt
        @setting_txt = {}
        url = Simple2ch.parse_and_generate_url(@url, :setting)
        data = Simple2ch.fetch url
        data.each_line do |d|
          if (split = d.split('=')).size == 2
            @setting_txt[split[0].to_sym] = split[1].chomp
          end
        end
      end
      @setting_txt[param.to_sym]
    end

    # TLDを返す
    # @return [Symbol] TLD. :net or :sc
    def tld
      @tld
    end

    def ==(board)
      self.updated_at == board.updated_at
    end

    # titleに合致するスレッドを取得する
    # @param [String] title タイトル
    # @return [Thre] タイトルが合致したスレッド or nil #TODO:Thre->Thread
    # @return [Thread] タイトルが合致したスレッド or nil
    def find(title)
      threads.find { |t| t.title==title }
    end

    # titleに合致するスレッドを得する
    # @param [String] title タイトル
    # @return [Thre] タイトルが合致したスレッド or nil #TODO:Thre->Thread
    # @return [Thread] タイトルが合致したスレッド or nil
    alias_method :[], :find

    # titleが含まれるスレッドを取得する
    # @param [String] title タイトル
    # @return [Thre] タイトルが含まれるスレッド #TODO: Thre->Thread
    def contain(title)
      threads.find { |b| b.title.index title }
    end

    # titleに合致するスレッドを全て取得する
    # @param [String] title タイトル
    # @return [Array<Thre>] タイトルが合致したスレッドの配列 #TODO: Thre->Thread
    def contain_all(title)
      threads.find_all { |b| b.title.index title }
    end

    private

    def validate_url(url)
      url_obj = URI.parse(url)
      parsed = Bbs2chUrlValidator::URL.parse(url_obj.to_s)
      return parsed.built_url if parsed && !parsed.board_name.empty?
      fail NotA2chBoardUrlError
    end

    # 板に属する全てのスレッドをsubject.txtから取得する
    # @return [Array<Thre>] 板に属する全てのスレッド
    def fetch_all_thres
      subject_url = Simple2ch.parse_and_generate_url(@url, :board)+'subject.txt'

      subject_txt = Simple2ch.fetch(subject_url)
      subject_txt.each_line do |line|
        @thres << Thre.parse(self, line)
      end
      @updated_at = Time.now
      @thres
    end
  end
end
