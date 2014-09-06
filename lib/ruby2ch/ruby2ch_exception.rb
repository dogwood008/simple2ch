module Ruby2ch
  class Ruby2chException < Exception; end
  class NotA2chUrlException < Ruby2chException; end
  class KakoLogException < Ruby2chException; end
  class DatParseException < Ruby2chException; end
end