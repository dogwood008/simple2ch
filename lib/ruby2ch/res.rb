module Simple2ch
  class Res
    # @return [Fixnum] レス番号
    attr_reader :res_num
    # @return [String] 投稿者名
    attr_reader :author
    # @return [String] ID
    attr_reader :author_id
    # @return [Time] 書き込み日時
    attr_reader :date
    # @return [String] メール欄
    attr_reader :mail
    # @return [String] 内容
    attr_reader :contents

    KAKO_LOG_INFO = '過去ログ ★<><>[過去ログ]<><em>■ このスレッドは過去ログ倉庫に格納されています</em><>'

    #
    # @param [Fixnum] res_num レス番号
    # @param [String] author 投稿者名
    # @param [String] author_id ID
    # @param [Time] date 書き込み日時
    # @param [String] mail メール欄
    # @param [String] contents 内容
    def initialize(res_num, author: '', author_id: '', date: nil, mail: '', contents: '')
      @res_num = res_num
      @author = author
      @author_id = author_id
      @date = date
      @mail = mail
      @contents = contents
    end

    # Datの1行から各項目を分離して、Resオブジェクトを返す
    # @param [Fixnum] res_num レス番号
    # @param [String] contents datのデータ1行
    # @return [Res] 新規Resオブジェクト
    # @raise [KakoLogException] 過去ログ情報をパースしようとした際に発生
    def self.parse(res_num, contents)
      unless contents.strip == KAKO_LOG_INFO
        self.new res_num, self.parse_dat(contents)
      else
        raise KakoLogException
      end
    end

    private
    # Datの1行から各項目を分離して、Resオブジェクトを返すメソッドの実体
    # @param [String] dat datのデータ1行
    # @raise [DatParseException] Datのパースに失敗したときに発生
    def self.parse_dat(dat)
      split_date_and_id_regex = /(^\d{4}\/\d{2}\/\d{2}\(.\) \d{2}:\d{2}:\d{2}\.\d{2}) ID:(\S+)$/
      ret = {}
      split = dat.split('<>')
      ret[:author] = split[0]
      ret[:mail] = split[1]
      date_and_author_id = split[2]
      ret[:contents] = split[3].strip!

      date_and_author_id =~ split_date_and_id_regex
      if !$1 || !$2
        raise DatParseException
      end
      ret[:date] = Time.parse $1
      ret[:author_id] = $2

      ret
    end
  end
end
