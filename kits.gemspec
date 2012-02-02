# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kits/version"

Gem::Specification.new do |s|
  s.name        = "kits"
  s.version     = Kits::VERSION
  s.authors     = ["Simen Svale Skogsrud"]
  s.email       = ["simen@bengler.no"]
  s.homepage    = ""
  s.summary     = %q{Provides Pebble parts kits with sinatra.}
  s.description = %q{Provides Pebble parts kits with sinatra.}

  s.rubyforge_project = "kits"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "sinatra"
  s.add_dependency "sprockets"
  s.add_development_dependency "fu"
  s.add_development_dependency "coffee-script"
  s.add_development_dependency "haml"
  s.add_development_dependency "mustache"
end
