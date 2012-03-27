# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kete_trackable_items/version"

Gem::Specification.new do |s|
  s.name        = "kete_trackable_items"
  s.version     = KeteTrackableItems::VERSION
  s.authors     = ["Walter McGinnis", "Noel Gomez", "Chris Toynbee"]
  s.email       = ["ctoynbee@gmail.com","walter@katipo.co.nz"]
  s.homepage    = ""
  s.summary     = %Q{A Rails engine gem that works in conjunction with kete_gets_trollied to track where an item (with a corresponding physical archive) is physically located.}
  s.description = %Q{A Kete application add-on that allows for tracking the location of an item in a physical archive that corresponds to the item in the Kete application.} 

  s.rubyforge_project = "kete_trackable_items"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "thoughtbot-shoulda"
  s.add_development_dependency "jeweler"
  # s.add_runtime_dependency "rest-client"
end
