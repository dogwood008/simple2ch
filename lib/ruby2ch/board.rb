class Board
  # @return [URI] 板のURL
  attr_reader :url
  # @return [String] 板の名前
  attr_reader :title


  # @param [String] tiitle 板の名前
  # @param [String] url 板のURL
  def initialize(title, url)
    @url = validate_url url
    @title = title
  end

  private
  # URLが正しいかバリデーションする
  # @param [String] url
  def validate_url(url)
    sp_uri = URI.parse url
    board_url = ''

    if sp_uri.host.index '2ch'
      case url
      when /http:\/\/(.+)\.2ch\.(net|sc)\/(.+)\/subject\.txt/
        board_url = URI.parse("http://#{$1}.2ch.sc/#{$3}/")
      when /http:\/\/(.+)\.2ch\.(net|sc)\/(.+)\//
        board_url = URI.parse("http://#{$1}.2ch.sc/#{$3}/")
      when /http:\/\/(.+)\.2ch\.(net|sc)\/(\w+)/
        board_url = URI.parse("http://#{$1}.2ch.sc/#{$3}/")
      when /http:\/\/(.+)\.2ch.(net|sc)\/test\/read.cgi\/(.+)\/([0-9]+)/
        board_url = URI.parse("http://#{$1}.2ch.sc/#{$3}/")
      when /http:\/\/(.+)\.2ch.(net|sc)\/(.+)\/dat\/([0-9]+)\.dat/
        board_url = URI.parse("http://#{$1}.2ch.sc/#{$3}/")
      else
        raise NotA2chUrlException
      end
    elsif url == DUMMY_URL
      board_url = DUMMY_URL
    else
      raise NotA2chUrlException
    end
  end
end