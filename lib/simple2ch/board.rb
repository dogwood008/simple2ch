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
    def initialize(title, url, fetch_title:nil)
      @server_name = @board_name = nil
      @url = validate_url url
      @title = if fetch_title
                 bbs.boards.find{|b|b.url==@url}.title
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
        url = Simple2ch.normalized_url(@url, :setting_txt)
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
      threads.find{|t|t.title==title}
    end

    # titleに合致するスレッドを得する
    # @param [String] title タイトル
    # @return [Thre] タイトルが合致したスレッド or nil #TODO:Thre->Thread
    # @return [Thread] タイトルが合致したスレッド or nil
    alias_method :[], :find

    # titleに合致する板を全て取得する
    # @param [String] title タイトル
    # @return [Array<Thre>] タイトルが合致したスレッドの配列 #TODO: Thre->Thread
    def find_all(title)
      threads.find_all { |b| b.title==title }
    end

    private
    # URLが正しいかバリデーションする
    # @param [URI] url
    # @raise [Simple2ch::NotA2chUrlException] 2chのフォーマットで無いURLを渡したときに発生
    # @raise [URI::InvalidURIError] そもそもURLのフォーマットで無いときに発生
    def validate_url(url)
      sp_uri = URI.parse url
      if sp_uri
        if sp_uri.host.index '2ch'
          parsed_url = Simple2ch.parse_url(url.to_s)
          @server_name = parsed_url[:server_name]
          @board_name = parsed_url[:board_name]
          @f_open2ch = !(parsed_url[:openflag].to_s.empty?)
          @tld = parsed_url[:tld]
          #URI.parse("http://#{server_name}.#{parsed_url[:openflag]}2ch.#{@tld}/#{board_name}/")
          URI.parse Simple2ch.normalized_url(url)
        else
          raise NotA2chUrlException, "Given URL :#{url}"
        end
      else
        raise URI::InvalidURIError
      end
    end

    # 板に属する全てのスレッドをsubject.txtから取得する
    # @return [Array<Thre>] 板に属する全てのスレッド
    def fetch_all_thres
      subject_url = @url+'subject.txt'

      subject_txt = Simple2ch::BBS.fetch(subject_url)
      subject_txt.each_line do |line|
        @thres << Thre.parse(self, line)
      end
      @updated_at = Time.now
      @thres
    end
  end
end