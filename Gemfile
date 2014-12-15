source 'https://rubygems.org'

gemspec

# use engine_cart instead of generic dummy app
gem 'engine_cart'

gem 'rubocop', require: false

gem 'database_cleaner', '~> 1.3.0', require: false

group :development do
  gem 'guard'
  gem 'guard-rspec', require: false
end

file = File.expand_path('Gemfile',
                        ENV['ENGINE_CART_DESTINATION'] ||
                        ENV['RAILS_ROOT'] ||
                        File.expand_path('../spec/internal', __FILE__))
if File.exist?(file)
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
else
  gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']

  # explicitly include sass-rails to get compatible dependencies
  if ENV['RAILS_VERSION'] && ENV['RAILS_VERSION'] =~ /^4.2/
    gem 'sass-rails', '~> 5.0.0'
    gem 'responders', '~> 2.0'
  else
    gem 'sass-rails', '~> 4.0.3'
  end
end
