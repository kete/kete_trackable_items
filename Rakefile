require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "kete_trackable_items"
    gem.summary = %{A Rails engine gem that works in conjunction with kete_gets_trollied to track where an item (with a corresponding physical archive) is physically located.}
    gem.description = %(A Kete application add-on that allows for tracking the location of an item in a physical archive that corresponds to the item in the Kete application.)
    gem.email = "walter@katipo.co.nz"
    gem.homepage = "http://github.com/kete/kete_trackable_items"
    gem.authors = ["Walter McGinnis", "Noel Gomez", "Chris Toynbee"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_dependency "kete_gets_trollied", ">= 0.0.3"
    gem.add_dependency "workflow", ">= 0.8.0"
    gem.add_dependency "ar-extensions", ">= 0.9.5"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  # in the future may include own tests under dummy app or generators for kete app specific tests.
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "kete_trackable_items #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
