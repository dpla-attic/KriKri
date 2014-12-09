require 'fileutils'
require 'jettywrapper'

namespace :jetty do

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
