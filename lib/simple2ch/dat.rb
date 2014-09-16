module Simple2ch
  class Dat
    # @return [String] スレッドキー
    attr_reader :thread_key

    # @param [Thre] thre スレッド
    def initialize(thre)
      @thre = thre
      @thread_key = thre.thread_key
      @data = nil
      @reses = nil
      @f_kako_log = nil
    end

    # Datを解析して、レスを返す
    # @return [Array<Res>] レス
    def reses
      parse_dat unless @reses
      @reses
    end

    # Datを解析して過去ログかどうかを返す
    # @return [Boolean] 過去ログか否か
    def kako_log?
      parse_dat if @f_kako_log.nil?
      @f_kako_log
    end

    private
    # datのURLを返す
    # @return [URI] datのURL
    def dat_url
      @thre.board.url+'dat/'+(@thread_key+'.dat')
    end

    # datファイルを取得する
    # @return [String] 取得したdatファイルの中身
    def fetch_dat
      @data ||= Simple2ch.fetch(dat_url)
    end

    # datファイルを解析してResを作成する
    def parse_dat
      res_num = 0
      @reses = []
      @f_kako_log = false
      fetch_dat.each_line do |l|
        res_num += 1
        begin
          @reses << Res.parse(res_num, l, @thre)
        rescue KakoLogException
          @f_kako_log = true
        end
      end
    end
  end
end