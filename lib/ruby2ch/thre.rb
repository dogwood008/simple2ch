class Thre
  # @return [String] 板の名前
  attr_reader :title

  # @param [String] thread_data 0000000000.dat<>スレッドタイトル (レス数)
  def initialize(thread_data)
    thread_data =~ /(\d{10})\.dat<>(.+) \((\d+)\)/
    @thread_key = $1
    @title = $2
    @num_of_response = $3
  end
end