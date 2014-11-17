require 'fileutils'

namespace :jetty do

  desc 'Configure solr schema'
  task :config do
    cp('solr_conf/schema.xml', 'jetty/solr/development-core/conf/schema.xml')
    cp('solr_conf/solrconfig.xml',
       'jetty/solr/development-core/conf/solrconfig.xml')
  end
end
