source 'https://rubygems.org'

gemspec

# use engine_cart instead of generic dummy app
gem 'engine_cart'

gem 'rubocop', require: false

file = File.expand_path('Gemfile',
                        ENV['ENGINE_CART_DESTINATION'] ||
                        ENV['RAILS_ROOT'] ||
                        File.expand_path('../spec/internal', __FILE__))
if File.exist?(file)
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
end
