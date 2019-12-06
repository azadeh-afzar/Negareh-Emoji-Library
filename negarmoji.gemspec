# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "negarmoji/version"

Gem::Specification.new do |spec|
  spec.name = "negarmoji"
  spec.version = Emoji::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Mohammad Mahdi Baghbani Pourvahid"]
  spec.email = "MahdiBaghbani@protonmail.com"
  spec.homepage = "https://gitlab.com/Azadeh-Afzar/Web-Development/Negareh-Emoji-Library"
  spec.description = "Character information and metadata for Unicode emoji."
  spec.summary = "Unicode emoji library."
  spec.licenses = "GPL-3.0"

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^test/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "minitest", "~> 5.13"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.77"
  spec.add_development_dependency "simplecov", "~> 0.17.0"
end
