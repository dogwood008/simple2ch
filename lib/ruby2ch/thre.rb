class Thre
  # @return [String] スレッドの名前
  attr_reader :title
  # @return [String] スレッドキー(Unix time)
  attr_reader :thread_key
  # @return [Fixnum] 返信の数
  attr_reader :num_of_response

  # @param [Board] board スレッドが属する板情報
  # @param [String] thread_data 0000000000.dat<>スレッドタイトル (レス数)
  def initialize(board, thread_data)
    @board = board
    thread_data =~ /(\d{10})\.dat<>(.+) \((\d+)\)/
    @thread_key = $1
    @title = $2
    @num_of_response = $3.to_i
    @reses = []
  end

  # スレッドに属する全てのレスを返す
  # @return [Array<Res>] スレッドに属する全てのレス
  def reses
    if @reses.size > 0
      @reses
    else
      @reses = parse_dat
    end
  end

  private
  # datのURLを返す
  # @return [URI] datのURL
  def dat_url
    @board.url+'dat/'+@thread_key+'.dat'
  end

  # datファイルを取得する
  # @return [String] 取得したdatファイルの中身
  def fetch_dat
    Ruby2ch.fetch dat_url
  end

  # datファイルを解析してResを作成する
  # @return [Array<Res>] 全てのレス
  def parse_dat
    res_num = 0
    tmp = []
    fetch_dat.each_line do |l|
      res_num += 1
      tmp << Res.new(res_num, l)
    end
    tmp
  end
end