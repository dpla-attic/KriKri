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
    end

    ##
    # Copy files from KriKri
    #
    # :force => true prevents user from having to manually accept
    # overwrite for files that are generated elsewhere
    def catalog_controller
      copy_file "catalog_controller.rb",
        "app/controllers/catalog_controller.rb", :force => true
    end

    def catalog_view_home
      copy_file "_home.html.erb", "app/views/catalog/_home.html.erb"
    end

  end

end
