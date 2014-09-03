require "ruby2ch/version"

module Ruby2ch
  require 'ruby2ch/board'
  require 'ruby2ch/dat'
  require 'ruby2ch/res'
  require 'ruby2ch/thread'
  # Your code goes here...
  def self.root
    File.dirname __dir__
  end
end

#TODO: テストの用意。
#TODO: コメントを書いてメソッドを整える。