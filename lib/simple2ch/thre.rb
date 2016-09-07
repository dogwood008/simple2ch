module Simple2ch
  class Thre
    # @return [String] スレッドキー(Unix time)
    attr_reader :thread_key
    # @return [Board] 属する板
    attr_reader :board
    # @return [Bbs2chUrlValidator::UrlInfo] URL
    attr_reader :url

    # @param [Board] board スレッドが属する板情報
    # @param [String] thread_key スレッドキー
    # @param [String] title スレッド名
    def initialize(url, title: nil)
      @title = title
      @url = if url.instance_of?(Bbs2chUrlValidator::UrlInfo)
               url
             else
               Bbs2chUrlValidator::URL.parse(url)
             end
      raise NotAThreadUrlError if @url.thread_key.nil?
    end

    # 板オブジェクトとsubject.txtの1行データを渡すとスレオブジェクトを返す
    # @param [Board] board スレッドが属する板情報
    # @param [String] thread_data 0000000000.dat<>スレッドタイトル (レス数)
    # @return [Thre] スレ
    #def self.parse(board, thread_data)
    #  thread_key, title =  thread_data.scan /(\d{10})\.dat<>(.+) \((\d+)\)/
    #  thread_data =~ /(\d{10})\.dat<>(.+) \((\d+)\)/
    #  hash = {}
    #  thread_key = $1
    #  hash[:title] = $2.force_encoding('utf-8')
    #  hash[:num_of_response] = $3.to_i
    #  self.new board, thread_key, hash
    #end

    # Datを解析して、レスを返す
    # @param [Array<Fixnum>,Fixnum] num_of_responses 取得したいレス番号
    def responses(num_of_responses = nil)
      fetch_dat if @responses.nil?
      case num_of_responses
      when Array
        raise 'Blank array was given.' if num_of_responses.empty?
        @responses.find_all { |r| num_of_responses.index(r.res_num) }
      when Fixnum
        @responses.find { |r| r.res_num == num_of_responses }
      when NilClass
        @responses
      end
    end
    alias response responses

    # 過去ログかどうかを返す
    # @return [Boolean] 過去ログか否か
    def kako_log?
      fetch_dat if @is_kako_log.nil?
      @is_kako_log
    end

    # 全てのレスに対し、あるレスへのアンカーが書き込まれているレス番号のハッシュを返す
    # @return [Hash]{ res_num<Fixnum> => res_nums<Array<Fixnum>> } レス番号のハッシュ
    def received_anchors
      @received_anchors ||= calc_received_anchors
    end

    # 2chタイプ名の取得
    # @return [Symbol] 2chタイプ名(:sc, :open)
    def type_of_2ch
      Simple2ch.type_of_2ch(@url.to_s)
    end

    ## スレのURLを返す
    ## @return [String] スレのURL
    #def url(board: nil, thread_key: nil, force_refresh: false)
    #  if @url && !force_refresh
    #    @url
    #  else
    #    if board
    #      parsed_url = Bbs2chUrlValidator::URL.parse(board.url.built_url)
    #      Simple2ch.generate_url(:thread, parsed_url, thread_key: thread_key)
    #    else
    #      fail "Not implemented."
    #    end
    #  end
    #end

    # タイトルを返す
    # @return [String] スレッドの名前
    def title
      fetch_dat unless @title
      @title
    end

    private

    # 全てのレスに対し、あるレスへのアンカーが書き込まれているレス番号のハッシュを返す
    # @return [Hash]{ res_num<Fixnum> => res_nums<Array<Fixnum>> } レス番号のハッシュ
    def calc_received_anchors
      ret = {}
      reses.each do |res|
        res.anchors.each do |anchor|
          ret.store(anchor, ret.fetch(anchor, []).push(res.res_num))
        end
      end
      ret
    end

    # Datを取ってきてレスと過去ログかどうかを返す
    # @return [Boolean] is_kako_log 過去ログか否か
    def fetch_dat
      dat = Dat.new(self)
      @responses = dat.reses
      @title = dat.title
      @is_kako_log = dat.kako_log?
    end
  end
end
