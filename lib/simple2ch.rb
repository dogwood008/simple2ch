require 'simple2ch/version'
require 'singleton'

module Simple2ch
  require_relative './simple2ch/simple2ch_exception'
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

  @@bbs = {}

  # HTTPでGETする
  # @param [URI] url URL
  # @return [String] 取得本文
  def self.fetch(url, encode = nil)
    encode ||= encoded_in_sjis?(url) ? 'sjis' : 'utf-8'
    errors_to_retry = [OpenURI::HTTPError, SocketError]
    Retryable.retryable(tries: 5, on: errors_to_retry, sleep: 3) do
      OpenURI.open_uri(url, "r:#{encode}")
             .read
             .encode('utf-8', undef: :replace, invalid: :replace, replace: '〓')
    end
  end

  # 2chのタイプを返す
  # @param [String] url URL
  # @return [Symbol] :open or :net or :sc
  # @raise [NotA2chUrlException] 2chのURLでないURLが与えられた際に発生
  def self.type_of_2ch(url)
    parsed_url = self.parse_url(url)
    openflag = parsed_url[:openflag]
    tld = parsed_url[:tld]
    if openflag && tld=='net'
      :open
    elsif !openflag && tld=='net'
      :net
    elsif !openflag && tld=='sc'
      :sc
    else
      raise NotA2chUrlException, "Given URL: #{url}"
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
