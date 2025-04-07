# frozen_string_literal: true

require_relative "lib/metimur/version"

Gem::Specification.new do |spec|
  spec.name = "metimur"
  spec.version = Metimur::VERSION
  spec.authors = ["Durable Programming Team"]
  spec.email = ["team@durableprogramming.com"]

  spec.summary = "Ruby source code parser and metadata manager"
  spec.description = "Parses Ruby source code and provides information about classes, methods and comments. Allows reading and writing source code comments."
  spec.homepage = "https://github.com/durableprogramming/metimur"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir.glob(%w[
                          lib/**/*
                          *.gemspec
                          LICENSE.txt
                          CHANGELOG.md
                          README.md
                          Gemfile
                          Rakefile
                        ])
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-inflector"
  spec.add_dependency "parser"
  spec.add_dependency "simplecov"
  spec.metadata["rubygems_mfa_required"] = "true"
end
