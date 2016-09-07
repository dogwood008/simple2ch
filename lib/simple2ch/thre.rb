module Simple2ch
  class Thre
    # @return [String] スレッドキー(Unix time)
    attr_reader :thread_key
    # @return [Fixnum] 返信の数
    attr_reader :num_of_response
    # @return [Board] 属する板
    attr_reader :board

    # @param [Board] board スレッドが属する板情報
    # @param [String] thread_key スレッドキー
    # @param [String] title スレッド名
    # @param [Fixnum] num_of_response 総書き込み数
    def initialize(board, thread_key, title: '', num_of_response: '')
      @board = board
      @thread_key = thread_key
      @title = title
      @num_of_response = num_of_response
      @url = url(board: board, thread_key: thread_key)
      @reses = nil
      @f_kako_log = nil
      @received_anchors = nil
    end

    # 板オブジェクトとsubject.txtの1行データを渡すとスレオブジェクトを返す
    # @param [Board] board スレッドが属する板情報
    # @param [String] thread_data 0000000000.dat<>スレッドタイトル (レス数)
    # @return [Thre] スレ
    def self.parse(board, thread_data)
      thread_key, title =  thread_data.scan /(\d{10})\.dat<>(.+) \((\d+)\)/
      thread_data =~ /(\d{10})\.dat<>(.+) \((\d+)\)/
      hash = {}
      thread_key = $1
      hash[:title] = $2.force_encoding('utf-8')
      hash[:num_of_response] = $3.to_i
      self.new board, thread_key, hash
    end

    # スレのURLからスレオブジェクトを生成して返す
    # @param [String] url URL
    # @return [Thre] スレ
    def self.create_from_url(url)
      board = Simple2ch::Board.new(nil, url)
      thread_key = Simple2ch.parse_url(url)[:thread_key]
      thre = board.thres.find{|t| t.thread_key == thread_key}
      unless thre
        thre = Thre.new board, thread_key
        thre.reses
      end
      thre
    end

    def reses(num_of_reses=nil)
      warn '[Deprecated] Thre#reses was called.'
      responses num_of_reses
    end
    # Datを解析して、レスを返す
    # @param [Array<Fixnum>,Fixnum] num_of_reses 取得したいレス番号
    # @return [Array<Res>] レスの配列
    def responses(num_of_reses=nil)
      fetch_dat unless @reses
      case num_of_reses
        when Array
          if num_of_reses.size > 0
            @reses.find_all { |r|
              num_of_reses.index(r.res_num)
            }
          else
            raise 'Blank array was given.'
          end
        when Fixnum
          @reses.find { |r| r.res_num == num_of_reses }
        when NilClass
          @reses
      end
    end
    alias_method :res, :reses

    # 過去ログかどうかを返す
    # @return [Boolean] 過去ログか否か
    def kako_log?
      fetch_dat if @f_kako_log.nil?
      @f_kako_log
    end

    # 全てのレスに対し、あるレスへのアンカーが書き込まれているレス番号のハッシュを返す
    # @return [Hash]{ res_num<Fixnum> => res_nums<Array<Fixnum>> } レス番号のハッシュ
    def received_anchors
      @received_anchors ||= calc_received_anchors
    end

    # 2chタイプ名の取得
    # @return [Symbol] 2chタイプ名(:sc, :open)
    def type_of_2ch
      @board ? @board.type_of_2ch : nil
    end

    # スレのURLを返す
    # @return [String] スレのURL
    def url(board: nil, thread_key: nil, force_refresh: false)
      if @url && !force_refresh
        @url
      else
        if board
          parsed_url = Bbs2chUrlValidator::URL.parse(board.url.built_url)
          Simple2ch.generate_url(:thread, parsed_url, thread_key: thread_key)
        else
          fail "Not implemented."
        end
      end
    end

    # スレのdatURLを返す
    # @return [String] スレのdatURL
    def dat_url
      tld = type_of_2ch == :sc ? :sc : :net
      "http://#{@board.server_name}.#{type_of_2ch==:open ? 'open' : ''}2ch.#{tld}/#{@board.board_name}/dat/#{@thread_key}.dat"
    end

    # タイトルを返す
    # @return [String] スレッドの名前
    def title
      unless @title
        fetch_dat
      end
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
    # @return [Boolean] f_kako_log 過去ログか否か
    def fetch_dat
      dat = Dat.new(self)
      @reses = dat.reses
      @num_of_response = @reses.size
      @f_kako_log = dat.kako_log?
      @title =  dat.title if !@title || @title.empty?
      dat = nil
      @f_kako_log
    end
  end
end
