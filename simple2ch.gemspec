# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple2ch/version'

Gem::Specification.new do |spec|
  spec.name          = "simple2ch"
  spec.version       = Simple2ch::VERSION
  spec.authors       = ["dogwood008"]
  spec.email         = ["dogwood008+rubygems@gmail.com"]
  spec.summary       = %q{A gem to read 2ch bbs.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/dogwood008/simple2ch"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-core"
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'spork'

  spec.required_ruby_version = '~> 2.0'

#  spec.add_development_dependency 'spring'
#  spec.add_development_dependency 'zeus'
#  spec.add_development_dependency 'guard'
#  spec.add_development_dependency 'guard-rspec'
#  spec.add_development_dependency 'guard-zeus'
end
