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
  s.add_dependency "rails_config", "~>0.4.0"
  s.add_dependency "audumbla", '~> 0.1'
  s.add_dependency "dpla-map", "4.0.0.0.pre.12"
  s.add_dependency "rest-client"
  s.add_dependency "rdf-marmotta", '>= 0.0.6'
  s.add_dependency "blacklight", "~>5.8.0"
  s.add_dependency "therubyracer"
  s.add_dependency "edtf"
  s.add_dependency "text"
  s.add_dependency "oai", '~>0.4.0'
  s.add_dependency "jsonpath"
  s.add_dependency "devise", "~>3.4.1"
  s.add_dependency "resque", "~>1.0"
  s.add_dependency "analysand", "4.0.0"
  s.add_dependency "yajl-ruby"
  s.add_dependency "elasticsearch", "~>0.4.0"

  ##
  # FIXME on Rails 4.2 upgrade: pin bootstrap-sass to 3.3.4.1
  #
  # This relates to sass/sass#1656. bootstrap-sass 3.3.5 introduced a
  # regression which causes the Blacklight default CSS to fail its build.
  # A quick fix could be to require sass-rails 5.0.x, but that introduces
  # some slight dependency resolution problems under Rails 4.1 since Rails 4.1
  # apps use sass-rails ~> 4.0.3 by default. The better fix will be to upgrade
  # Krikri to Rails 4.2, but that will require further testing. This change
  # has to be in the gemspec, and not the Gemfile for Krikri or the
  # application in which it is hosted, as the dependencies won't resolve
  # properly.
  s.add_dependency "bootstrap-sass", "3.3.4.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "jettywrapper", '~> 2.0'
  s.add_development_dependency "rspec-rails", '~> 3.2.0'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'factory_girl_rails', '~>4.4.0'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'timecop'
end
