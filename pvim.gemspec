# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pvim/version'

Gem::Specification.new do |spec|
  spec.name          = "pvim"
  spec.version       = Pvim::VERSION
  spec.authors       = ["Phong Nguyen"]
  spec.email         = ["nhphong1406@gmail.com"]
  spec.description   = %q{Pvim is tool for managing vim plugins using Pathogen with Git Submodules}
  spec.summary       = spec.description
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "thor", '~> 0.18'
end
