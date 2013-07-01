# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "action_jackson/version"

Gem::Specification.new do |s|
  s.name        = "action-jackson"
  s.version     = ActionJackson::VERSION
  s.authors     = ["Blake Taylor", "David Chen"]
  s.email       = ["blakefrost@gmail.com", "mvjome@gmail.com"]
  s.homepage    = "https://github.com/blakefrost/action_jackson"
  s.summary     = %q{DSL for defining dependencies between rails actions and before_filters.}

  s.rubyforge_project = "action_jackson"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rake"
  s.add_dependency "actionpack"
  s.add_dependency "activesupport"
  s.add_dependency "rspec-rails"

  s.add_development_dependency 'pry-debugger'
  s.add_development_dependency 'rspec-rails', '~> 2.0' 
end
