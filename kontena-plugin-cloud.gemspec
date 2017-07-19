# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kontena/plugin/cloud'

Gem::Specification.new do |spec|
  spec.name          = "kontena-plugin-cloud"
  spec.version       = Kontena::Plugin::Cloud::VERSION
  spec.authors       = ["Kontena, Inc."]
  spec.email         = ["info@kontena.io"]

  spec.summary       = "Kontena Cloud management for Kontena CLI"
  spec.description   = "Kontena Cloud management for Kontena CLI"
  spec.homepage      = "https://kontena.io"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'kontena-cli', '>= 1.3.0'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end
