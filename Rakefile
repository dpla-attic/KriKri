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

import 'lib/tasks/jetty.rake'

desc "Run all specs in spec directory (excluding plugin specs) in an engine_cart-generated app"
task :ci => ['jetty:clean', 'engine_cart:clean', 'engine_cart:generate'] do
  Rake::Task['jetty:config'].invoke

  Jettywrapper.wrap(quiet: true,
                    jetty_port: 8983,
                    startup_wait: 30,
                    java_opts: ["-Dmarmotta.home=#{MARMOTTA_HOME}"]) do
    Rake::Task["spec"].invoke
  end
end

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec)
task :default => :ci
