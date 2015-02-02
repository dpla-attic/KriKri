require 'fileutils'
require 'jettywrapper'

namespace :jetty do
  Jettywrapper.url = 'https://github.com/dpla/marmotta-jetty/archive/3.3.0-solr-4.9.0.zip'

  MARMOTTA_HOME = ENV['MARMOTTA_HOME'] || File.expand_path(File.join(Jettywrapper.app_root, 'jetty', 'marmotta'))

  desc 'Configure solr schema'
  task :config do
    cp('solr_conf/schema.xml', 'jetty/solr/development-core/conf/schema.xml')
    cp('solr_conf/solrconfig.xml',
       'jetty/solr/development-core/conf/solrconfig.xml')
  end

  desc 'Remove the jetty and marmotta directories and recreate them'
  task :clean do
    FileUtils.rm_rf(MARMOTTA_HOME)
    Jettywrapper.clean
  end
end
