module Simple2ch
  require 'socket'
  require 'open-uri'
  require 'time'
  require 'charwidth'
  require 'retryable'

  class BBS
    attr_reader :type_of_2ch, :boards, :updated_at

    def initialize(type_of_2ch)
      case type_of_2ch
      when :sc, :open
        @type_of_2ch = type_of_2ch
      else
        raise %{Invalid "type_of_2ch" given: #{type_of_2ch} (:sc or :open is correct.)}
      end
      @updated_at = Time.now
    end

    def root
      File.dirname __dir__
    end

    # @option [Boolean] force_reload キャッシュを利用せず板リストを再取得する
    # @return [Array<Simple2ch::Board>] 板リスト
    def boards(force_reload: nil, bbsmenu_url: nil)
      if force_reload
        @boards = fetch_boards(bbsmenu_url)
      else
        @boards ||= fetch_boards(bbsmenu_url)
      end
    end

    private

    def fetch_boards(bbsmenu_url = nil)
      bbsmenu_urls = {
        sc: 'http://2ch.sc/bbsmenu.html', open: 'http://open2ch.net/bbsmenu.html'
      }

      bbsmenu_url = bbsmenu_urls[type_of_2ch] if bbsmenu_url.nil?
      data = Simple2ch.fetch(URI.parse(bbsmenu_url))
      raise "Failed to fetch #{bbsmenu_url}" if data.empty?
      scaned_data = data.scan(Regex::BOARD_EXTRACT_REGEX).uniq
      raise "Failed to parse #{bbsmenu_url}" if scaned_data.empty?

      boards = scaned_data.map do |b|
        Simple2ch::Board.new(b[4], "http://#{b[0]}.#{b[1]}2ch.#{b[2]}/#{b[3]}/")
      end
      boards.compact
    end
  end
end
