module Simple2ch
  class Simple2chException < Exception; end
  class NotA2chUrlException < Simple2chException; end
  class KakoLogException < Simple2chException; end
  class DatParseException < Simple2chException; end
  class NoThreGivenException < Simple2chException; end
end