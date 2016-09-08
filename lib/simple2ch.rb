require 'simple2ch/version'
require 'singleton'

module Simple2ch
  require_relative './simple2ch/simple2ch_error'
  require_relative './simple2ch/board'
  require_relative './simple2ch/dat'
  require_relative './simple2ch/res'
  require_relative './simple2ch/thre'
  require_relative './simple2ch/regex'
  require_relative './simple2ch/bbs'
  require 'socket'
  require 'open-uri'
  require 'time'
  require 'charwidth'
  require 'retryable'
  require 'bbs_2ch_url_validator'
  require 'pry'

  @@bbs = {}

  # HTTPでGETする
  # @param [URI or Bbs2chUrlValidator::UrlInfo or String] url URL
  # @return [String] 取得本文
  def self.fetch(url, encode = nil)
    url_obj = URI.parse(url.to_s)
    encode ||= encoded_in_sjis?(url) ? 'sjis' : 'utf-8'
    errors_to_retry = [OpenURI::HTTPError, SocketError]
    Retryable.retryable(tries: 5, on: errors_to_retry, sleep: 3) do
      OpenURI.open_uri(url_obj, "r:#{encode}")
             .read
             .encode('utf-8', undef: :replace, invalid: :replace, replace: '〓')
    end
  end

  # 2chのタイプを返す
  # @param [String] url URL
  # @return [Symbol] :open or :net or :sc
  # @raise [NotA2chUrlError] 2chのURLでないURLが与えられた際に発生
  def self.type_of_2ch(url)
    parsed_url = Bbs2chUrlValidator::URL.parse(url)
    raise NotA2chUrlError, "Given URL: #{url}" unless parsed_url
    case true
    when parsed_url.is_open && parsed_url.tld == 'net'
      :open
    when !parsed_url.is_open && parsed_url.tld == 'net'
      :net
    when !parsed_url.is_open && parsed_url.tld == 'sc'
      :sc
    else
      binding.pry
      raise NotA2chUrlError, "Given URL: #{url}"
    end
  end

  # @param [Object] url
  # @param [Hash] type
  def self.generate_url(type, url, params = {})
    # bbs:     http://www.2ch.sc/, http://open2ch.net/
    # board:   http://viper.2ch.sc/news4vip/, http://viper.open2ch.net/news4vip/
    # dat:     http://viper.2ch.sc/news4vip/dat/9990000001.dat, http://viper.open2ch.net/news4vip/dat/1439127670.dat
    # subject: http://viper.2ch.sc/news4vip/subject.txt, http://viper.open2ch.net/news4vip/subject.txt
    # setting: http://viper.2ch.sc/news4vip/SETTING.TXT, http://viper.open2ch.net/news4vip/SETTING.TXT
    # thread:  http://viper.2ch.sc/test/read.cgi/news4vip/9990000001/, http://viper.open2ch.net/test/read.cgi/news4vip/1439127670

    url_obj = Bbs2chUrlValidator::URL.parse(url.to_s)
    domain = "#{url_obj.open? ? 'open' : ''}2ch.#{url_obj.tld}"
    board_name = params[:board_name] ? params[:board_name] : url_obj.board_name
    case type
    when :bbs
      "http://www.#{domain}.#{url_obj.tld}/"
    when :board
      "http://#{url_obj.server_name}.#{domain}/#{board_name}/"
    when :dat
      url_obj.dat
    when :subject
      url_obj.subject
    when :setting
      url_obj.setting
    when :thread
      thread_key = params[:thread_key] ? params[:thread_key] : url_obj.thread_key
      "http://#{url_obj.server_name}.#{domain}/test/read.cgi/#{board_name}/#{thread_key}/"
    end
  end

  private

  def encoded_in_sjis?(url)
    url.to_s.include?('subject.txt') ||
      url.to_s.include?('SETTING.TXT') ||
      url.to_s.include?('.dat') ||
      url.to_s.include?('bbsmenu')
  end
end
