module Simple2ch
  class Regex
    # http://www.rubular.com/r/u1TJbQAULD
    BOARD_EXTRACT_REGEX = /<A HREF=http:\/\/(?<subdomain>\w+).(?<openflag>open|)2ch.(?<tld>sc|net)\/(?<board_name>\w+)\/>(?<board_name_ja>.+)<\/A>/
  end
end