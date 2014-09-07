module Simple2ch
  class Thre
    # @return [String] スレッドの名前
    attr_reader :title
    # @return [String] スレッドキー(Unix time)
    attr_reader :thread_key
    # @return [Fixnum] 返信の数
    attr_reader :num_of_response
    # @return [Board] 属する板
    attr_reader :board

    # @param [Board] board スレッドが属する板情報
    # @param [String] thread_data 0000000000.dat<>スレッドタイトル (レス数)
    def initialize(board, thread_data)
      @board = board
      thread_data =~ /(\d{10})\.dat<>(.+) \((\d+)\)/
      @thread_key = $1
      @title = $2
      @num_of_response = $3.to_i
      @reses = nil
      @f_kako_log = nil
    end

    # Datを解析して、レスを返す
    # @return [Array<Res>] レスの配列
    def reses
      @reses || fetch_dat[0]
    end

    # 過去ログかどうかを返す
    # @return [Boolean] 過去ログか否か
    def kako_log?
      @f_kako_log || fetch_dat[1]
    end

    private
    # Datを取ってきてレスと過去ログかどうかを返す
    # @return [Array<Res>] reses レス
    # @return [Boolean] f_kako_log 過去ログか否か
    def fetch_dat
      dat = Dat.new(self)
      @reses, @f_kako_log = dat.reses, dat.kako_log?
      dat = nil
      return @reses, @f_kako_log
    end

    #TODO: スコアリング
  end
end