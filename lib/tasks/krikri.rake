require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'dpla/map/factories'
require '../../app/models/krikri/original_record.rb'
require '../../spec/factories/krikri_original_record.rb'
require 'open-uri'
require 'resque/tasks'

require 'krikri/index_service'

namespace :krikri do
  namespace :samples do

    # Note: The content of the sample original record does not actually
    # correspond to the content of the sample aggregation.
    desc 'Save a sample record to Marmotta and Solr'
    task :save_record => :environment do
      original_record = build(:oai_dc_record)
      original_record.save unless original_record.exists?

      # Make a DPLA::MAP::Aggregation with an original record instantiated as an
      # ActiveTriples::Resource object.
      agg = build(:aggregation,
                  :originalRecord => ActiveTriples::Resource
                                  .new(original_record.rdf_subject)
            )

      agg.mint_id!('krikri_sample')

      # Save to Marmotta
      agg.save unless agg.exists?

      # Save to Solr
      graph = agg.to_jsonld['@graph'].first
      Krikri::IndexService.add graph.to_json
      Krikri::IndexService.commit
    end

    desc 'Save an invalid sample record to Marmotta and Solr'
    task :save_invalid_record => :environment do
      original_record = build(:json_record)
      original_record.save unless original_record.exists?

      agg = build(:aggregation,
                  :originalRecord => ActiveTriples::Resource
                                      .new(original_record.rdf_subject),
                  :sourceResource => build(:source_resource, title: nil)
            )

      agg.mint_id!('krikri_sample_invalid')

      # Save to Marmotta
      agg.save unless agg.exists?

      # Save to Solr
      graph = agg.to_jsonld['@graph'].first
      Krikri::IndexService.add graph.to_json
      Krikri::IndexService.commit
    end

    desc 'Delete all sample records from Marmotta and Solr'
    task :delete_record => :environment do
      # Delete aggregation from Marmotta
      agg = DPLA::MAP::Aggregation.new
      agg.mint_id!('krikri_sample')
      agg.delete! if agg.exists?

      agg = DPLA::MAP::Aggregation.new
      agg.mint_id!('krikri_sample_invalid')
      agg.delete! if agg.exists?

      # Delete original records from Marmotta
      original_record = build(:oai_dc_record)
      original_record.delete! if original_record.exists?

      original_record = build(:json_record)
      original_record.delete! if original_record.exists?

      # Delete all sample records from Solr
      Krikri::IndexService.delete_by_query 'id:*krikri_sample*'
      Krikri::IndexService.commit
    end

    desc 'Save sample institution and harvest source'
    # the '=> :environment' dependency gives task access to ActiveRecord models
    task :save_institution => :environment do

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
    task :delete_institution => :environment do
      # any harvest sources associated with sample institution will be
      # destroyed through dependent_destroy
      institution = Krikri::Institution.find_by(name: 'Krikri Sample Institution')
      institution.destroy if institution
    end
  end
end
