module Simple2ch
  class Response
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

    KAKO_LOG_INFO = '過去ログ ★<><>[過去ログ]<><em>■ このスレッドは過去ログ倉庫に格納されています</em><>'.freeze

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
    # @raise [KakoLogError] 過去ログ情報をパースしようとした際に発生
    def self.parse(res_num, contents)
      raise KakoLogError if contents.strip == KAKO_LOG_INFO
      hash = parse_dat(contents)
      self.new(res_num, hash)
    end

    # アンカーを抽出する　荒らしの場合は空配列を返す
    # @return [Array<Fixnum>] 昇順ソート済みアンカー、荒らしの場合は空配列
    def anchors
      arashi_removal_regex = /(?:\d{1,4}(?:\]*>)?(?:>|\[＞,+-\]){1,2}){9}/
      return [] if self.contents =~ arashi_removal_regex
      splitter_regex = '[,、， 　]'
      digit_regex = '(?:\d|[０-９])+'
      hyphen_regex = '[−ｰー\-〜~〜]'
      extracted = self.contents.scan /&gt;((?:#{digit_regex}(?:#{splitter_regex}|#{hyphen_regex})*)+)/
      anchors = extracted.flatten.to_s.gsub(/[\"\[\]]/, '').split(/#{splitter_regex}/)
      anchors.delete('')
      anchors.map! do |a|
        if a =~ /(#{digit_regex})#{hyphen_regex}(#{digit_regex})/
          (Range.new parseInt($1), parseInt($2)).to_a
        else
          parseInt(a)
        end
      end
      anchors.flatten.uniq.sort
    end

    # あぼーんレスか否か
    # @return [Boolean] あぼーんならtrue
    def abone?
      @date == 'あぼーん'
    end

    # レスの内容をテキスト情報で得る。&nbsp, &lt, &gt, <br>はそれぞれ「 」、「<」、「>」、「(改行)」に置換される。
    # @return [String] テキスト情報でのレスの内容
    def contents_text
      require 'htmlentities'
      anchor_regex = /<a href="\.\.\/test\/read.cgi\/.+\/\d{10}\/\d{1,4}" target="_blank">(>>\d{1,4})<\/a>/
      @htmlentities ||= HTMLEntities.new
      @htmlentities.decode(@contents).gsub('<br>', "\n").gsub(/<\/?b>/, '').gsub(anchor_regex, '\1')
    end

    # HTMLタグを取り除いた投稿者名
    # @return <String> HTMLタグを取り除いた投稿者名
    def res_author_text
      require 'htmlentities'
      @htmlentities ||= HTMLEntities.new
      @htmlentities.decode(@author).gsub('<br>', "\n").gsub(/<\/?b>/, '')
    end

    private

    # 全角数字をFixnumへ変換する
    # @param [String] strnum 全角数字
    # @return [Fixnum] 数字
    def parseInt(strnum)
      (Charwidth.normalize strnum).to_i
    end

    # Datの1行から各項目を分離して、Resオブジェクトを返すメソッドの実体
    # @param [String] dat datのデータ1行
    # @raise [DatParseError] Datのパースに失敗したときに発生
    def self.parse_dat(dat)
      split_date_and_id_regex = /(?<time>^\d{4}\/\d{2}\/\d{2}\(.\) ?\d{2}:\d{2}:\d{2}(\.\d{2,3})?)(?: ID:(?<author_id>(\S|.)+)$)?/
      ret = {}
      split = dat.split('<>')
      ret[:author] = split[0]
      ret[:mail] = split[1]
      date_and_author_id = split[2]
      ret[:contents] = split[3].strip

      if split_date_and_id_regex =~ date_and_author_id
        ret[:date] = Time.parse $~[:time]
        ret[:author_id] = $~[:author_id]
      else
        if dat.index 'あぼーん'
          return a_bone_data
        elsif dat.index 'Over 1000 Thread'
          # do nothing
        else
          raise DatParseError, "Data didn't match regex. Data:#{date_and_author_id}"
        end
      end

      ret
    end
  end

  def a_bone_data
    {
      author: 'あぼーん',
      mail: 'あぼーん',
      contents: 'あぼーん',
      date: 'あぼーん',
      author_id: 'あぼーん',
    }
  end
end
