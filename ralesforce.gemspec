# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ralesforce/version"

Gem::Specification.new do |s|
  s.name        = "ralesforce"
  s.version     = Ralesforce::VERSION
  s.authors     = ["Daniel Kador"]
  s.email       = ["dkador@salesforce.com"]
  s.homepage    = ""
  s.summary     = %q{A CLI to the SFDC API}
  s.description = %q{A CLI to the SFDC API}

  s.rubyforge_project = "ralesforce"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_dependency "trollop"
  s.add_dependency "rest_client"
  s.add_dependency "savon"
  s.add_dependency "json"
  s.add_dependency "libxml-ruby"
end
