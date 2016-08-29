module Simple2ch
  require 'socket'
  require 'open-uri'
  require 'time'
  require 'charwidth'
  require 'retryable'

  @@bbs = {}

  class BBS
    attr_reader :type_of_2ch, :boards, :updated_at
    # class variables
    @boards = {}

    def initialize(type_of_2ch)
      @@bbs = {} unless defined? @@bbs
      @boards = {}
      case type_of_2ch
      when :sc, :open
        @type_of_2ch = type_of_2ch
        @boards = get_boards_by_type_of_2ch @type_of_2ch
      else
        fail RuntimeError, %Q{Invalid "type_of_2ch" given: #{type_of_2ch} (:sc or :open is correct.)}
      end
      @@bbs[type_of_2ch] = self
      @updated_at = Time.now
    end

    def root
      File.dirname __dir__
    end

    # titleに合致する板を取得する
    # @param [String] title タイトル
    # @return [Board] タイトルが合致した板 or nil
    def find(title)
      boards.find { |b| b.title==title }
    end

    # titleを含むする板を取得する
    # @param [String] title タイトル
    # @return [Board] タイトルが含まれるた板 or nil
    alias_method :[], :find

    # titleが含まれる板を取得する
    # @param [String] title タイトル
    # @return [Board] タイトルが含まれる板
    def contain(title)
      boards.find { |b| b.title.index title }
    end

    # titleに合致する板を全て取得する
    # @param [String] title タイトル
    # @return [Array<Board>] タイトルが合致した板の配列
    def contain_all(title)
      boards.find_all { |b| b.title.index title }
    end

    # bbsmenuのURLが渡されればセットして，板リストを返す
    # @param [Symbol] type_of_2ch :sc or :open
    # @option [Boolean] force_reload キャッシュを利用せず板リストを再取得する
    # @return [Array<Simple2ch::Board>] 板リスト
    def boards(type_of_2ch, force_reload: nil)
      if force_reload || @@bbs.fetch(type_of_2ch, nil).nil?
        fail RuntimeError, '"type_of_2ch" is nil.' unless type_of_2ch
        bbsmenu_urls = {
          sc: 'http://2ch.sc/bbsmenu.html', open: 'http://open2ch.net/bbsmenu.html'
        }

        prepared_bbsmenu_url = bbsmenu_urls[type_of_2ch]

        fail RuntimeError, "Failed to fetch #{url}" if (data = Simple2ch.fetch(URI.parse(prepared_bbsmenu_url))).empty?
        fail RuntimeError, "Failed to parse #{url}" if (scaned_data=data.scan(Regex::BOARD_EXTRACT_REGEX).uniq).empty?

        scaned_data.map { |b|
          Simple2ch::Board.new(b[4], "http://#{b[0]}.#{b[1]}2ch.#{b[2]}/#{b[3]}/") rescue nil
        }.compact
      else
        @@bbs[type_of_2ch].boards
      end
    end

    alias_method :get_boards_by_type_of_2ch, :boards

    def <<(board)
      size = { before: @boards.size,
               after: @boards.delete_if { |b| b==board }.size }
      @boards << board

      if size[:before] - size[:after] > 0
        bbs = @@bbs.fetch(@type_of_2ch, Simple2ch::BBS.new(@type_of_2ch))
        bbs.boards.replace @boards
      end
    end
  end
end
