$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "krikri/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "krikri"
  s.version     = Krikri::VERSION
  s.authors     = ["Tom Johnson"]
  s.email       = ["tech@dp.la"]
  s.homepage    = "http://github.com/dpla/KriKri"
  s.summary     = "KriKri ingests objects."
  s.description = "Metadata aggregation and enrichment for cultural heritage institutions."
  s.license     = "Unspecified"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.1.6"
  s.add_dependency "dpla-map", "~>4.0.0.0-pre"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "marmottawrapper", '>=0.0.5'
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'pry-rails'
end
