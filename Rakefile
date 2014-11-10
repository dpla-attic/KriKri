begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Krikri'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'

require 'engine_cart/rake_task'
require 'jettywrapper'
require 'marmottawrapper'

ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.9.0.zip"

desc "Run all specs in spec directory (excluding plugin specs) in an engine_cart-generated app"
task :ci => ['engine_cart:generate'] do
  Jettywrapper.wrap(quiet: true, jetty_port: 8983, :startup_wait => 30) do
    Rake::Task["spec"].invoke
  end
end

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec)
task :default => :ci
