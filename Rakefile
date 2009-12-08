require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "vrtx"
    gem.summary = %Q{Extensions to the WebDAV client Net::HTTP for use with the Vortex CMS}
    gem.description = %Q{WebDAV client library for use with the Vortex CMS library using Net::HTTP}
    gem.email = "c1.github@niftybox.net"
    gem.homepage = "http://github.com/thomasfl/vrtx"
    gem.authors = ["Thomas Flemming", "Lise Hamre"]
    gem.executables = ["vrtx"]
    gem.add_dependency "net_dav", ">= 0.0.4"
    gem.add_development_dependency "rspec", ">= 1.2.0"
    gem.add_development_dependency "webrick-webdav", ">= 1.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

desc "release with no version change"
task :dist => [:clean, :release]

namespace :dist do
  desc "release patch"
  task :patch => [:clean, "version:bump:patch", :release]
  desc "release with minor version bump"
  task :minor => [:clean, "version:bump:minor", :release]
end

desc "build gem into pkg directory"
task :gem => [:build]

task :clean do
  Dir.glob("**/*~").each do |file|
    File.unlink file
  end
  puts "cleaned"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "net_dav #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

