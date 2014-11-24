require 'active_support'
require 'rails_config'
require 'krikri/ldp'

require 'rdf/marmotta'
require 'oai/client'

module Krikri
  ##
  # Krikri provides metadata aggregation and enhancement services.
  class Engine < ::Rails::Engine
    isolate_namespace Krikri

    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    initializer 'settings' do
      conf_path = root.join('config')
      setting_files = [conf_path.join('settings.yml'),
                       conf_path.join('settings', "#{Rails.env}.yml"),
                       conf_path.join('environments', "#{Rails.env}.yml"),
                       conf_path.join('settings.local.yml'),
                       conf_path.join('settings', "#{Rails.env}.local.yml"),
                       conf_path.join('environments', "#{Rails.env}.local.yml")
                      ].map(&:to_s)

      settings_const = Kernel.const_get(RailsConfig.const_name)

      source_paths = settings_const.add_source!('nil')[0..-2].map(&:path)
      source_paths = setting_files + source_paths

      RailsConfig.load_and_set_settings(source_paths)
      Krikri::Settings = Kernel.const_get(RailsConfig.const_name)
    end

    initializer :append_migrations do |app|
      unless app.root.to_s == root.to_s
        config.paths['db/migrate'].expanded.each do |exp_path|
          app.config.paths['db/migrate'] << exp_path
        end
      end
    end

  end
end
