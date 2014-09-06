class Res
  # @return [Fixnum] レス番号
  attr_reader :res_num
  # @return [String] 名前
  attr_reader :author
  # @return [String] ID
  attr_reader :author_id
  # @return [Time] 書き込み日時
  attr_reader :date
  # @return [String] メール欄
  attr_reader :mail
  # @return [String] 内容
  attr_reader :contents


  def initialize(res_num, author: '', author_id: '', date: nil, mail: '', contents: '')
    @res_num = res_num
    @author = author
    @author_id = author_id
    @date = date
    @mail = mail
    @contents = contents
  end

  def self.parse(res_num, contents)
    self.new res_num, self.parse_dat(contents)
  end

  private
  def self.parse_dat(dat)
    split_date_and_id_regex = /(^\d{4}\/\d{2}\/\d{2}\(.\) \d{2}:\d{2}:\d{2}\.\d{2}) ID:(\S+)$/
    ret = {}
    split = dat.split('<>')
    ret[:author] = split[0]
    ret[:mail] = split[1]
    date_and_author_id = split[2]
    ret[:contents] = split[3].strip!

    date_and_author_id =~ split_date_and_id_regex
    ret[:date] = Time.parse $1
    ret[:author_id] = $2

    ret
  end


end
