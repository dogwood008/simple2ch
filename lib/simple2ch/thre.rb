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
    # @param [String] thread_key スレッドキー
    # @param [String] title スレッド名
    # @param [Fixnum] num_of_response 総書き込み数
    def initialize(board, thread_key, title: '', num_of_response: '')
      @board = board
      @thread_key = thread_key
      @title = title
      @num_of_response = num_of_response
      @reses = nil
      @f_kako_log = nil
    end

    # 板オブジェクトとsubject.txtの1行データを渡すとスレオブジェクトを返す
    # @param [Board] board スレッドが属する板情報
    # @param [String] thread_data 0000000000.dat<>スレッドタイトル (レス数)
    # @return [Thre] スレ
    def self.parse(board, thread_data)
      thread_data =~ /(\d{10})\.dat<>(.+) \((\d+)\)/
      hash = {}
      thread_key = $1
      hash[:title] = $2
      hash[:num_of_response] = $3.to_i
      self.new board, thread_key, hash
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
  end
end