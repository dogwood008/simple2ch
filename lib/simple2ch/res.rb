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
    # @attr_writer [Thre] thre スレッド
    attr_writer :thre

    KAKO_LOG_INFO = '過去ログ ★<><>[過去ログ]<><em>■ このスレッドは過去ログ倉庫に格納されています</em><>'

    #
    # @param [Fixnum] res_num レス番号
    # @param [String] author 投稿者名
    # @param [String] author_id ID
    # @param [Time] date 書き込み日時
    # @param [String] mail メール欄
    # @param [String] contents 内容
    def initialize(res_num, author: '', author_id: '', date: nil, mail: '', contents: '', thre: nil)
      @res_num = res_num
      @author = author
      @author_id = author_id
      @date = date
      @mail = mail
      @contents = contents
      @thre = thre
    end

    # Datの1行から各項目を分離して、Resオブジェクトを返す
    # @param [Fixnum] res_num レス番号
    # @param [String] contents datのデータ1行
    # @return [Res] 新規Resオブジェクト
    # @raise [KakoLogException] 過去ログ情報をパースしようとした際に発生
    def self.parse(res_num, contents, thre=nil)
      unless contents.strip == KAKO_LOG_INFO
        hash = parse_dat(contents)
        hash[:thre] = thre if thre
        return self.new(res_num, hash)
      else
        raise KakoLogException
      end
    end

    # アンカーを抽出する　荒らしの場合は空配列を返す
    # @return [Array<Fixnum>] 昇順ソート済みアンカー、荒らしの場合は空配列
    def anchors
      arashi_removal_regex = /(?:\d{1,4}(?:\]*>)?(?:>|\[＞,+-\]){1,2}){9}/
      unless self.contents =~ arashi_removal_regex
        splitter_regex = '[,、， 　]'
        digit_regex = '(?:\d|[０-９])+'
        hyphen_regex = '[−ｰー\-〜~〜]'
        extracted = self.contents.scan /&gt;((?:#{digit_regex}(?:#{splitter_regex}|#{hyphen_regex})*)+)/
        anchors = extracted.flatten.to_s.gsub(/[\"\[\]]/,'').split(/#{splitter_regex}/)
        anchors.delete('')
        anchors.map! do |a|
          if a =~ /(#{digit_regex})#{hyphen_regex}(#{digit_regex})/
            (Range.new parseInt($1), parseInt($2)).to_a
          else
            parseInt(a)
          end
        end
        anchors.flatten.uniq.sort
      else
        []
      end
    end

    # 自レスへのアンカーが書き込まれているレス番号を返す
    # @return [Array<Fixnum>] レス番号
    def received_anchors
      thre = get_thre
      received_anchors = thre.received_anchors
      received_anchors.fetch(@res_num, [])
    end

    private
    # スレッドを取得する
    # @return [Thre] スレッド
    def get_thre
      if @thre
        @thre
      else
        raise NoThreGivenException
      end
    end

    # 全角数字をFixnumへ変換する
    # @param [String] strnum 全角数字
    # @return [Fixnum] 数字
    def parseInt(strnum)
      (Charwidth.normalize strnum).to_i
    end

    # Datの1行から各項目を分離して、Resオブジェクトを返すメソッドの実体
    # @param [String] dat datのデータ1行
    # @raise [DatParseException] Datのパースに失敗したときに発生
    def self.parse_dat(dat)
      split_date_and_id_regex = /(^\d{4}\/\d{2}\/\d{2}\(.\) \d{2}:\d{2}:\d{2}\.\d{2})(?: ID:(\S+)$){0,1}/
      ret = {}
      split = dat.split('<>')
      ret[:author] = split[0]
      ret[:mail] = split[1]
      date_and_author_id = split[2]
      ret[:contents] = split[3].strip

      date_and_author_id =~ split_date_and_id_regex
      if !$1
        raise DatParseException, "Parsed URL: #{thre.url}"
      end
      ret[:date] = Time.parse $1
      ret[:author_id] = $2

      ret
    end
  end
end
