require 'rubygems'
require 'ruby2ch'

# カスタムマッチャを書きたかったらここに。
RSpec::Matchers.define :my_matcher do |expected|
  match do |actual|
    true
  end
end
