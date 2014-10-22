require 'rails/generators'
require 'rails/generators/migration'

module Krikri

  class Install < Rails::Generators::Base

    def run_required_generators
      generate "blacklight:install --devise"
    end

  end

end
