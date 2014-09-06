class Thre
  # @return [String] スレッドの名前
  attr_reader :title
  # @return [String] スレッドキー(Unix time)
  attr_reader :thread_key
  # @return [Fixnum] 返信の数
  attr_reader :num_of_response
  attr_reader :board
  attr_accessor :f_kako_log

  # @param [Board] board スレッドが属する板情報
  # @param [String] thread_data 0000000000.dat<>スレッドタイトル (レス数)
  def initialize(board, thread_data)
    @board = board
    thread_data =~ /(\d{10})\.dat<>(.+) \((\d+)\)/
    @thread_key = $1
    @title = $2
    @num_of_response = $3.to_i
    @reses = []
    @kako_log = nil
  end

end