# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "stepstepstep"
  s.version     = "0.0.1"
  s.authors     = ["Blake Taylor", "David Chen"]
  s.email       = ["blakefrost@gmail.com", "mvjome@gmail.com"]
  s.homepage    = "https://github.com/eoecn/stepstepstep"
  s.summary     = %q{DSL for defining before_filters's dependencies like rake tasks.}
  s.description = File.read("README.markdown").split(/===+/)[0].strip
  s.license     = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rake"
  s.add_dependency "rails"
  s.add_dependency "actionpack"
  s.add_dependency "activesupport"

  s.add_development_dependency 'pry-debugger'
  s.add_development_dependency 'rspec-rails', '~> 2.0'
  s.add_development_dependency 'guard-rspec'

end
