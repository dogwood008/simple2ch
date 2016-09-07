module Simple2ch
  class Simple2chError < StandardError; end
  class NotA2chUrlError < Simple2chError; end
  class NotA2chBoardUrlError < Simple2chError; end
  class KakoLogError < Simple2chError; end
  class DatParseError < Simple2chError; end
  class NoThreGivenError < Simple2chError; end
end
