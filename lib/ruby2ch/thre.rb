class Thre
  # @return [String] スレッドの名前
  attr_reader :title
  # @return [String] スレッドキー(Unix time)
  attr_reader :thread_key
  # @return [int] 返信の数
  attr_reader :num_of_response

  # @param [String] thread_data 0000000000.dat<>スレッドタイトル (レス数)
  def initialize(thread_data)
    thread_data =~ /(\d{10})\.dat<>(.+) \((\d+)\)/
    @thread_key = $1
    @title = $2
    @num_of_response = $3
  end
end