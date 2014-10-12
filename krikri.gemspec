$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "krikri/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "krikri"
  s.version     = Krikri::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Krikri."
  s.description = "TODO: Description of Krikri."
  s.license     = "Unspecified"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.6"

  s.add_development_dependency "sqlite3"
end
