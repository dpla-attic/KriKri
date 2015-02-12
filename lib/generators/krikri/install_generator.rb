require 'rails/generators'
require 'rails/generators/migration'

module Krikri

  class Install < Rails::Generators::Base

    source_root File.expand_path("../templates", __FILE__)

    ##
    # Add factory girl dependency for development
    # FactoryGirl is used to generate sample data
    # jettywrapper is used to spin up Jetty running Solr and Marmotta
    # This must execute before run_required_generators
    def insert_development_dependencies
      gem 'factory_girl_rails', group: :development, version: '~> 4.4.0'
      gem 'jettywrapper', group: :development, version: '~> 2.0'
      gem 'pry-rails', group: :development
    end

    ##
    # Add solr configuration
    def configure_solr
      copy_file 'schema.xml', 'solr_conf/schema.xml', :force => true
      copy_file 'solrconfig.xml', 'solr_conf/solrconfig.xml', :force => true
    end

    ##
    # Add jetty configuration
    def configure_jetty
      copy_file '../../../../config/jetty.yml', 'config/jetty.yml'
    end

    ##
    # Install Devise
    # Devise is a dependency, and is specified in krikri.gemspec,
    # but it requires some setup if it's generated into
    # a development environment.
    def install_devise_dependency
      gem 'devise', version: '~> 3.4.1'
      generate "devise:install"
      generate "devise User"
      rake("db:migrate")
    end

    def run_required_generators
      generate "blacklight:install"
    end

    ##
    # Add the krikri routes
    # This will add routes at with the krikri namespace in the name
    # For example:
    #   /krikri/institutions
    def inject_krikri_routes
      route "mount Krikri::Engine => '/krikri'"
      gsub_file 'config/routes.rb', /^\s*blacklight_for.*/ do |match|
        "#" + match + " # provided by KriKri::Engine"
      end

      gsub_file 'config/routes.rb', /^\s*root.*/ do |match|
        "#" + match + " # replaced by spotlight_root"
      end
      route 'root to: "krikri/records#index"'
    end

    ##
    # Copy controllers from KriKri
    # :force => true prevents user from having to manually accept
    # overwrite for files that are generated elsewhere.
    def copy_krikri_controllers
      copy_file "application_controller.rb",
        "app/controllers/application_controller.rb", :force => true
      copy_file "catalog_controller.rb",
        "app/controllers/catalog_controller.rb", :force => true
    end
  end
end
