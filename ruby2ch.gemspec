# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby2ch/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby2ch"
  spec.version       = Ruby2ch::VERSION
  spec.authors       = ["kit"]
  spec.email         = ["kit@mbp"]
  spec.summary       = %q{A library to get 2ch bbs.}
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'spring'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
end
