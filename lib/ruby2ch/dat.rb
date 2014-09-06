class Dat
  attr_reader :thread_key
  attr_reader :f_kako_log

  # @param [Thre] スレッド
  def initialize(thre)
    @thre = thre
    @thread_key = thre.thread_key
    @data = nil
    @reses = nil
    @f_kako_log = nil
  end

  def reses
    @reses, @f_kako_log=parse_dat unless @reses

    @reses
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
    @data || (@data = Ruby2ch.fetch dat_url)
  end

  # datファイルを解析してResを作成する
  # @return [Array<Res>] 全てのレス
  def parse_dat
    res_num = 0
    tmp = []
    f_kako_log = false
    fetch_dat.each_line do |l|
      res_num += 1
      begin
        tmp << Res.parse(res_num, l)
      rescue KakoLogException
        f_kako_log = true
      end
    end
    return tmp, f_kako_log
  end
end