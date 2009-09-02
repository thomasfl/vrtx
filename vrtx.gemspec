spec = Gem::Specification.new do |s|
  s.name = "vrtx"
  s.version = "0.0.1"
  s.author = "Thomas Flemming"
  s.email = "thomas.flemming@gmail.com"
  s.homepage = "http://folk.uio.no/thomasfl"
  s.platform = Gem::Platform::RUBY
  s.summary = "Command line utility for Vortex CMS."
  s.description = "Client library and command line tool for " +
                   "managing content on webservers with WebDAV " +
                   "and the open source Vortex CMS."
  s.requirements << "cURL command line tool available from http://curl.haxx.se/"
  s.requirements << "Servername, username and password must be supplied in ~/.netrc file."
  s.files = ["lib/vrtx.rb", "bin/vrtx"]
  s.executables = ["vrtx"]
  s.require_path = "lib"
  s.rubyforge_project = "vrtx"
  #  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  s.add_dependency("davclient", ">= 0.0.1")
  s.add_dependency("hpricot", ">= 0.6")
  s.add_dependency("zentest", ">= 3.5")
end

