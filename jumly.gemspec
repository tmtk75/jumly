# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jumly/version"

Gem::Specification.new do |s|
  s.name        = "jumly"
  s.version     = Jumly::VERSION
  s.authors     = ["Tomotaka Sakuma"]
  s.email       = ["ktmtmks@gmail.com"]
  s.homepage    = "https://jumlyweb.appspot.com"
  s.summary     = %q{JUMLY is a JavaScript library to render UML diagram on client side, which is written in CoffeeScript.}
  s.description = %q{}

  s.rubyforge_project = "jumly"

  s.files = %w[
    public/javascripts/jumly-min.js
    public/stylesheets/jumly-min.css
    ]
  #s.files         = `git ls-files`.split("\n")
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
