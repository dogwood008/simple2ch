require 'rubygems'
require 'simple2ch'
require 'rspec'
require 'rspec/its'
include Simple2ch

RSpec::Matchers.define :have_news4vip do
  match do |boards|
    !boards.nil? && (news4vip = boards.find { |b| b.title == 'ニュー速VIP' }) && news4vip.url.to_s.index('news4vip')
  end
end

RSpec::Matchers.define :be_valid_responses do
  match do |thread|
    case thread.type_of_2ch
      when :sc, :open
        fetch_and_validate_first_res_from_html(thread.url, thread.type_of_2ch)
      else
        fail "Invalid type_of_2ch was given: #{thread.type_of_2ch}"
    end
  end
end

def open2ch_thread_data_example
  source_url = 'http://viper.open2ch.net/news4vip/subback.html'
  source = Simple2ch.fetch(source_url)
  if source =~ Simple2ch::Regex::OPEN2CH_THREAD_DATA_EXAMPLE_REGEX
    url = "http://viper.open2ch.net#{$1}"
    title = $2
    { url: url, title: title }
  else
    fail RuntimeError, "Could not fetch source url: #{source_url}"
  end
end

def fetch_first_res_from_html(source_url, type_of_2ch)
  source = Simple2ch.fetch source_url
  case type_of_2ch
    when :sc
      if source =~ Simple2ch::Regex::SC2CH_FIRST_RES_DATA_EXAMPLE_REGEX
        $1
      else
        nil
      end
    when :open
      source =~ Simple2ch::Regex::OPEN2CH_FIRST_RES_DATA_EXAMPLE_REEGEX
  end
end
