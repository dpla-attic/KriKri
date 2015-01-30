require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'dpla/map/factories'
require 'open-uri'
require 'resque/tasks'

require 'krikri/index_service'

namespace :krikri do

  # Tasks will execute in spec/internal unless directory is changed
  desc 'Index a valid sample aggregation'
  task :index_sample_aggregation do
    agg = build(:aggregation)

    graph = agg.to_jsonld['@graph'][0]

    # prepend "krikri_sample" to @id so that sample data can be identified for
    # deletion
    graph['@id'] = 'krikri_sample' + graph['@id']

    Krikri::IndexService.add graph.to_json
    Krikri::IndexService.commit
  end

  desc 'Index aggregations with missing required values'
  task :index_invalid_aggregation do

    agg = build(:aggregation,
                :sourceResource => build(:source_resource, title: nil)
    )

    graph = agg.to_jsonld['@graph'][0]
    graph['@id'] = 'krikri_sample_invalid'

    Krikri::IndexService.add graph.to_json
    Krikri::IndexService.commit
  end

  desc 'Delete all sample aggregations from solr'
  task :delete_sample_aggregation do
    Krikri::IndexService.delete_by_query 'id:krikri_sample*'
    Krikri::IndexService.commit
  end

  desc 'Create sample institution and harvest source'
  # the '=> :environment' dependency gives task access to ActiveRecord models
  task :create_sample_institution => :environment do

    unless Krikri::Institution.find_by(name: 'Krikri Sample Institution')

      institution = Krikri::Institution.create(
        name: 'Krikri Sample Institution',
        notes: 'These are notes about the Krikri Sample Institution.'
      )

      Krikri::HarvestSource.create(
        institution_id: institution.id,
        name: 'OAI feed',
        source_type: 'OAI',
        metadata_schema: 'MARC',
        uri: 'http://www.example.com',
        notes: 'These are notes about the Krikri Sample Source.'
      )

    end
  end

  desc 'Delete sample institution and harvest source'
  task :delete_sample_institution => :environment do
    # any harvest sources associated with sample institution will be
    # destroyed through dependent_destroy
    institution = Krikri::Institution.find_by(name: 'Krikri Sample Institution')
    institution.destroy if institution
  end

end
