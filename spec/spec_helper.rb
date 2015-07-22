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
