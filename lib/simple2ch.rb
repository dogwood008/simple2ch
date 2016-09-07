require 'simple2ch/version'
require 'singleton'

module Simple2ch
  require_relative './simple2ch/simple2ch_exception'
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

  @@bbs = {}

  # HTTPでGETする
  # @param [URI] url URL
  # @return [String] 取得本文
  def self.fetch(url, encode=nil)
    unless encode
      encode = if url.to_s.index('subject.txt') || url.to_s.index('SETTING.TXT') || url.to_s.index('.dat') || url.to_s.index('bbsmenu')
                 'SHIFT_JIS'
               else
                 'UTF-8'
               end
    end
    Retryable.retryable(tries: 5, on: [OpenURI::HTTPError, SocketError], sleep: 3) do
      got_binary = OpenURI.open_uri(url, 'r:binary').read
      got_string = got_binary.force_encoding(encode).encode('utf-8', undef: :replace, invalid: :replace, replace: '〓')
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
end
