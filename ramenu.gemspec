# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ramenu/version"

Gem::Specification.new do |gem|
  gem.authors = ["Thomas Kienlen", "Simone Carletti"]
  gem.email = "thomas.kienlen@lafourmi-immo.com"
  gem.description = "Ramenu is a simple Ruby on Rails plugin for creating and managing navigation menus for a Rails project."
  gem.summary = "Rails 'A la carte' menu plugin for creating and managing navigation menus."
  gem.homepage = "https://github.com/lafourmi/ramenu"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.name          = "ramenu"
  gem.require_paths = ["lib"]
  gem.version = Ramenu::VERSION

  gem.add_dependency 'rails', ">= 3.0"
  gem.add_development_dependency 'appraisal', ">= 0"
  gem.add_development_dependency 'mocha', "~> 0.9.10"
  gem.add_development_dependency 'yard', ">= 0"
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rack-test'
  unless ENV["CI"]
    gem.add_development_dependency "turn", "~> 0.9" if defined?(RUBY_VERSION) && RUBY_VERSION > '1.9'
  end
end
