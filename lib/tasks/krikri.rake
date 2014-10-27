require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'dpla/map/factories'
require 'open-uri'

namespace :krikri do

  # Tasks will execute in spec/internal unless directory is changed
  desc 'Index sample data in solr'
  task :index_sample_data do
    agg = build(:aggregation)

    graph = agg.to_jsonld['@graph'][0]

    # prepend "krikri_sample" to @id so that sample data can be identified for
    # deletion
    # TODO: add ids with prefixes (or similar identification) to factories
    graph['@id'] = 'krikri_sample' + graph['@id']

    Krikri::IndexService.add graph.to_json
    Krikri::IndexService.commit
  end

  desc 'Delete sample data from solr'
  task :delete_sample_data do
    Krikri::IndexService.delete_by_query 'id:krikri_sample*'
    Krikri::IndexService.commit
  end
end
