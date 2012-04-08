# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "scrambler/version"

Gem::Specification.new do |s|
  s.name        = "scrambler"
  s.version     = Scrambler::VERSION
  s.authors     = ["Graham Brooks"]
  s.email       = ["graham@grahambrooks.com"]
  s.homepage    = ""
  s.summary     = %q{Source code metrics collection}
  s.description = %q{Collects and publishes source code metrics to scramble instances}
  s.executables << 'scrambler'
  s.rubyforge_project = "scrambler"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "json"
  s.add_runtime_dependency "svn2git"
end
