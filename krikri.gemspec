$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "krikri/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "krikri"
  s.version     = Krikri::VERSION
  s.authors     = ['Audrey Altman',
                   'Mark Breedlove',
                   'Tom Johnson',
                   'Mark Matienzo']
  s.email       = ["tech@dp.la"]
  s.homepage    = "http://github.com/dpla/KriKri"
  s.summary     = "A Rails engine for metadata aggregation, enhancement, and quality control."
  s.description = "Metadata aggregation and enrichment for cultural heritage institutions."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.1.6"
  s.add_dependency "rails_config"
  s.add_dependency "audumbla", '~> 0.1'
  s.add_dependency "dpla-map", "4.0.0.0.pre.10"
  s.add_dependency "rest-client"
  s.add_dependency "rdf-marmotta", '>= 0.0.6'
  s.add_dependency "blacklight", "~>5.8.0"
  s.add_dependency "therubyracer"
  s.add_dependency "edtf"
  s.add_dependency "text"
  s.add_dependency "oai"
  s.add_dependency "jsonpath"
  s.add_dependency "devise", "~>3.4.1"
  s.add_dependency "resque", "~>1.0"
  s.add_dependency "analysand", "4.0.0"
  s.add_dependency "yajl-ruby"
  s.add_dependency "elasticsearch", "~>0.4.0"
  s.add_dependency "sass-rails", "~> 5.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "jettywrapper", '~> 2.0'
  s.add_development_dependency "rspec-rails", '~> 3.2.0'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'factory_girl_rails', '~>4.4.0'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'timecop'
end
