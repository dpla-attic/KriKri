require 'database_cleaner'

RSpec.configure do |config|

  # clear database completely before test suite runs
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  # set default database cleaning strategy to be transactions
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
