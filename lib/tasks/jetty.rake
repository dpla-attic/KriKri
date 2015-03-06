require 'fileutils'
require 'jettywrapper'

namespace :jetty do
  Jettywrapper.url = 'https://github.com/dpla/marmotta-jetty/archive/3.3.0-solr-4.10.3.zip'

  DEFAULT_MARMOTTA = File.expand_path(File.join(Jettywrapper.app_root,
                                                'jetty',
                                                'marmotta'))
  MARMOTTA_HOME = ENV['MARMOTTA_HOME'] || DEFAULT_MARMOTTA

  desc 'Configure solr schema'
  task :config do
    cp('solr_conf/schema.xml', 'jetty/solr/development-core/conf/schema.xml')
    cp('solr_conf/solrconfig.xml',
       'jetty/solr/development-core/conf/solrconfig.xml')
  end

  desc 'Empty the Marmotta home directory used by Jettywrapper'
  task :clean_marmotta_home do
    FileUtils.rm_rf(MARMOTTA_HOME) unless MARMOTTA_HOME == DEFAULT_MARMOTTA
  end

  task :clean => [:clean_marmotta_home]
end
