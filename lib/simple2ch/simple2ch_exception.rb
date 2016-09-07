module Simple2ch
  # @deprecated Use XxxError
  class Simple2chException < StandardError; end
  # @deprecated Use XxxError
  class NotA2chUrlException < Simple2chException; end
  # @deprecated Use XxxError
  class NotA2chBoardUrlException < Simple2chException; end
  # @deprecated Use XxxError
  class KakoLogException < Simple2chException; end
  # @deprecated Use XxxError
  class DatParseException < Simple2chException; end
  # @deprecated Use XxxError
  class NoThreGivenException < Simple2chException; end
end
