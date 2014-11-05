ENV['RAILS_ENV'] ||= 'test'

require 'engine_cart'
EngineCart.load_application!

require 'rspec/rails'
require 'rspec/autorun'
require 'webmock/rspec'
require 'factory_girl_rails'

require 'dpla/map/factories'
require 'rdf/marmotta'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

WebMock.disable_net_connect!(:allow_localhost => true)

RSpec.configure do |config|
  config.color = true
  config.formatter = :progress
  config.mock_with :rspec

  config.include FactoryGirl::Syntax::Methods

  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'

  def clear_repository
    RDF::Marmotta.new(Krikri::Settings['marmotta']['base']).clear!
  end

  config.before(:suite) do
    clear_repository
  end

  config.after(:suite) do
    clear_repository
  end
end
