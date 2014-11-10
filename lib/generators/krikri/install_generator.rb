require 'rails/generators'
require 'rails/generators/migration'

module Krikri

  class Install < Rails::Generators::Base

    source_root File.expand_path("../templates", __FILE__)

    ##
    # Add factory girl dependency for development
    # Factory girl is used to generate sample data
    # This must execute before run_required_generators
    def insert_factory_girl_dependency
      append_to_file "Gemfile" do 
        "\n\n#KriKri uses Factory Girl to generate sample data
        gem 'factory_girl_rails', '~>4.4.0', group: :development"
      end
    end

    def run_required_generators
      generate "blacklight:install --devise"
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
