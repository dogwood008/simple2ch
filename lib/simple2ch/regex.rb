module Simple2ch
  class Regex
    # http://www.rubular.com/r/u1TJbQAULD
    BOARD_EXTRACT_REGEX = /<A HREF=http:\/\/(?<subdomain>\w+).(?<openflag>open|)2ch.(?<tld>sc|net)\/(?<board_name>\w+)\/>(?<board_name_ja>.+)<\/A>/
    # http://www.rubular.com/r/a43KJpItsL
    OPEN2CH_THREAD_DATA_EXAMPLE_REGEX = /^<a href="(\/test\/read.cgi\/\w+\/\d{10}\/)l50">1: (.+) \(\d+\)<\/a>$/
    # http://www.rubular.com/r/tjZefqnhP2
    SC2CH_FIRST_RES_DATA_EXAMPLE_REGEX = /<dt>1 ：<font color=green><b>(.+)<\/b><\/font>：/
    # http://www.rubular.com/r/Mn3dPVrtXc
    OPEN2CH_FIRST_RES_DATA_EXAMPLE_REEGEX = /^<dl><dt res=1><a class=num val=1 href=.\/1>1<\/a> ：<font color=#1c740d><b>(.+)<\/b>.+font color=red>主<\/font>/

    constants(true).each do |c|
      eval "#{c}.freeze"
    end
  end
end