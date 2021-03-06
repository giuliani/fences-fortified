# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fences/fortified/version'

Gem::Specification.new do |spec|
  spec.name          = "fences-fortified"
  spec.version       = Fences::Fortified::VERSION
  spec.authors       = ["Giuliani Perry"]
  spec.email         = ["perryg.88@gmail.com"]

  spec.summary       = "Fences Fortified is an adaptation of the Fences library. Created to provide authorization for your Ruby on Rails app."
  spec.homepage      = "https://github.com/giuliani/fences-fortified"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_dependency "activerecord"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
