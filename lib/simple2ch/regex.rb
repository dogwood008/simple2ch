module Simple2ch
  class Regex
    # http://www.rubular.com/r/u1TJbQAULD
    BOARD_EXTRACT_REGEX = /<A HREF=http:\/\/(?<subdomain>\w+).(?<openflag>open|)2ch.(?<tld>sc|net)\/(?<board_name>\w+)\/>(?<board_name_ja>.+)<\/A>/
    # http://www.rubular.com/r/a43KJpItsL
    OPEN2CH_THREAD_DATA_EXAMPLE_REGEX = /^<a href="(\/test\/read.cgi\/\w+\/\d{10}\/)l50">1: (.+) \(\d+\)<\/a>$/

    constants(true).each do |c|
      eval "#{c}.freeze"
    end
  end
end