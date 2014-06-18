# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_auth/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_auth"
  spec.version       = SimpleAuth::VERSION
  spec.authors       = ["Dominik Cencek"]
  spec.email         = ["me@dominikcencek.com"]
  spec.summary       = "Simple authorization library"
  spec.description   = ""
  spec.homepage      = "http://github.com/dominikc/simple_auth"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "rspec"
end
