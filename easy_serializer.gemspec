# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_serializer/version'

Gem::Specification.new do |spec|
  spec.name          = "easy_serializer"
  spec.version       = EasySerializer::VERSION
  spec.authors       = ["Artur Pañach"]
  spec.email         = ["arturictus@gmail.com"]

  spec.summary       = %q{Semantic serializer for making easy serializing objects.}
  spec.description   = %q{Semantic serializer for making easy serializing objects.}
  spec.homepage      = "https://github.com/arturictus/easy_serializer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_dependency 'activesupport', '~> 4.2'
end
