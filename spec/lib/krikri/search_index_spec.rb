require 'spec_helper'
require 'elasticsearch'

# Skip tests like those requiring an ElasticSearch connection by setting
# the enrironment variable CI=yes, such as
# $ CI=yes bundle exec rspec spec/lib/krikri/search_index_spec.rb
if ENV['CI'] == 'yes'
  RSpec.configure do |c|
    c.filter_run_excluding ci_skip: true
  end
end

describe Krikri::SearchIndex do
  subject { described_class.new bulk_update_size: 2 }

  describe '#bulk_update_batches' do
    let(:aggs) { ["JSON string"] * 3 }

    it 'returns the right number of documents' do
      all = subject.send(:bulk_update_batches, aggs)
      doc_count = 0
      batch_count = 0
      all.each do |batch|
        doc_count += batch.count
        batch_count += 1
      end
      expect(doc_count).to eq 3
      expect(batch_count).to eq 2
    end
  end

  describe '#update_from_activity' do
    before { allow(activity).to receive(:entities).and_return(aggs) }

    let(:aggs) { [build(:aggregation), build(:aggregation)] }
    let(:activity) { double('activity') }
    
    it 'adds each record' do
      expect(subject).to receive(:add).exactly(aggs.count).times
      subject.update_from_activity(activity)
    end

    it 'logs errors' do
      allow(subject).to receive(:add).and_raise(RuntimeError)
      expect(Rails.logger).to receive(:error).exactly(2).times
      subject.update_from_activity(activity)
    end
  end
end


describe Krikri::QASearchIndex do
  let(:solr) { RSolr.connect }

  describe '#initialize' do
    context 'with overridden properties' do
      subject { described_class.new(opts) }
      let(:opts) { { url: 'http://my-client-uri/' } }

      it 'passes options to RSolr client' do
        expect(subject.solr.uri.to_s).to eq opts[:url]
      end
    end

    it 'defaults to Krikri::Settings.solr' do
      uri = 'http://moomin.org/'
      allow(Krikri::Settings)
        .to receive(:solr).and_return(url: uri)
      expect(subject.solr.uri.to_s).to eq uri
    end

    context 'with extra properties not covered by defaults' do
      # see https://www.pivotaltracker.com/n/projects/1172184/stories/91822774
      # Note that `url` is not specified in `opts`:
      let(:opts) { { extra_prop: 'not covered by defaults' } }
      subject { described_class.new(opts) }

      it 'preserves defaults by merging extra properties' do
        uri = 'http://moomin.org/'
        allow(Krikri::Settings)
          .to receive(:solr).and_return(url: uri)
        expect(subject.solr.uri.to_s).to eq uri
      end
    end
  end

  describe '#solr_doc' do
    context 'without models' do
      before :each do
        fake_schema_keys = ['a', 'b', 'c', 'b_c', 'b_d']
        allow(subject).to receive(:schema_keys).and_return(fake_schema_keys)
      end

      it 'converts JSON into Solr-compatible hash' do
        orig = { 'a' => '1', 'b' => { 'c' => '2', 'd' => '3' } }
        flat_hash = { 'a' => '1', 'b_c' => '2', 'b_d' => '3' }
        expect(subject.solr_doc(orig)).to eq flat_hash
      end

      it 'converts JSON with multiple child nodes into Solr-compatible hash' do
        json = { 'a' => '1',
                 'b' => [{ 'c' => '2', 'd' => '3' },
                         { 'c' => '4', 'd' => '5' },
                         'abc'],
                 'c' => ['abc', 'def'] }
        flat_hash = { 'a' => '1',
                      'b' => 'abc',
                      'b_c' => ['2', '4'],
                      'b_d' => ['3', '5'],
                      'c' => ['abc', 'def'] }
        expect(subject.solr_doc(json)).to eq flat_hash
      end


      it 'removes special character strings from keys' do
        json = {
          'http://www.geonames.org/ontology#a' => '1',
          'http://www.w3.org/2003/01/geo/wgs84_pos#b' => '2',
          '@c' => '3'
        }
        flat_hash = { 'a' => '1', 'b' => '2', 'c' => '3' }
        expect(subject.solr_doc(json)).to eq flat_hash
      end

      it 'removes keys that are not in solr schema' do
        json = { 'a' => '1', 'invalid_key' => '0' }
        valid_hash = { 'a' => '1' }
        expect(subject.solr_doc(json)).to eq valid_hash
      end
    end

    context 'with models' do
      let(:aggregation) { build(:aggregation) }

      before do
        subject.delete_by_query('id:*')
        subject.commit
        aggregation.set_subject!('http://api.dp.la/item/123')
        aggregation.provider << build(:krikri_provider, rdf_subject: 'snork')
          .agent
        subject.add aggregation.to_jsonld['@graph'][0]
        subject.commit
      end

      after do
        subject.delete_by_query('id:*')
        subject.commit
      end

      it 'posts DPLA MAP JSON to solr' do
        response = solr.get('select', :params => { :q => '' })['response']
        expect(response['numFound']).to eq 1
      end
    end

    describe '#schema_keys' do
      it 'returns an Array of keys' do
        result = subject.schema_keys
        expect(result).to be_a(Array)
        expect(result).not_to be_empty
      end
    end
  end  # #solr_doc

  describe '#update_from_activity' do
    include_context 'provenance queries'
    include_context 'entities query'

    # This is not totally realistic because we're indexing the records from a
    # mapping activity, instead of an enrichment activity, but we can change
    # that when we're able to enqueue an enrichment and have a valid agent
    # class name stored in `activities`.`agent`.
    # See the activities factory for generator_uri,
    # spec/factories/krikri_activities.rb.
    # See also spec/support/shared_contexts/generated_entities_query.rb, where
    # the activity factories are run.
    let(:activity) { Krikri::Activity.find_by_id(3) }  # the mapping activity
    # :generator_uri corresponds to the id of the :activity.
    # See provenance_query_client.rb ('provenance queries' shared context)
    let(:generator_uri) { 'http://localhost:8983/marmotta/ldp/activity/3' }

    it 'sends bulk add requests' do
      expect(subject).to receive(:bulk_add).at_least(1).times
      subject.update_from_activity(activity)
    end

    it 'calls commit' do
      expect(subject.solr).to receive(:commit)
      subject.update_from_activity(activity)
    end
  end
end


describe Krikri::ProdSearchIndex do
  let(:opts) { Krikri::Settings.elasticsearch.to_h }
  subject { described_class.new(opts) }

  context 'with arguments to #initialize' do
    describe '#initialize' do
      context 'with arguments' do
        it 'passes options to the ElasticSearch client' do
          expect(subject.elasticsearch.transport.options[:host])
            .to eq 'localhost:9200'  # per config/settings/test.yml
        end
        it 'sets its index name' do
          expect(subject.index_name).to eq 'dpla_test'  # as above
        end
      end
    end
  end

  context 'with an ElasticSearch connection', ci_skip: true do
    host = Krikri::Settings.elasticsearch.host
    es = Elasticsearch::Client.new host: host
    index_name = Krikri::Settings.elasticsearch.index_name
    let(:aggregation) { build(:aggregation) }
    before(:all) do
      # create the index and set the schema
      begin
        es.indices.delete index: index_name
      rescue
      end
      es.indices.create index: index_name,
                        body: {
                          settings: ELASTICSEARCH_SETTINGS,
                          mappings: ELASTICSEARCH_MAPPING
                        }
    end
    after(:all) do
      # tear down the index
      es.indices.delete index: index_name
    end

    describe '#update_from_activity' do
      include_context 'provenance queries'
      include_context 'entities query'
      # See above re. :activity and :generator_uri
      let(:activity) { Krikri::Activity.find_by_id(3) }
      let(:generator_uri) { 'http://localhost:8983/marmotta/ldp/activity/3' }

      it 'updates records affected by an activity' do
        # TODO: remove this mock when
        # Krikri::ProdSearchIndex#hash_for_index_schema is complete.
        allow_any_instance_of(Krikri::ProdSearchIndex)
          .to receive(:hash_for_index_schema)
          .and_return(MAP3_JSON_HASH)
        expect do
          subject.update_from_activity(activity)
        end.to_not raise_error
      end
    end
  end

end


ELASTICSEARCH_SETTINGS = {
  'analysis' => {
    'analyzer' => {
      'canonical_sort' => {
      'type' => 'custom',
        'tokenizer' => 'keyword',
        'filter' => ['lowercase', 'pattern_replace'],
      },
    },
    'filter' => {
      'pattern_replace' => {
        'type' => 'pattern_replace',
        # any combination of layered leading non-alphanumerics and/or leading stopwords: a, an, the
        'pattern' => '^([^a-z0-9]+|a\b|an\b|the\b)*',
        'replacement' => '',
      }
    }
  }
}

ELASTICSEARCH_MAPPING = {
  'collection' => {
    'date_detection' => false,
    'properties' => {
      '@id' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field' },
      'admin' => {
        'properties' => {
          'valid_after_enrich' => { 'type' => 'boolean'},
          'validation_message' => { 'enabled' => 'false'},
          'ingestType' => { 'enabled' => false },
          'ingestDate' => { 'type' => 'date' },
        }
      },
      'description' => { 'type' => 'string' },
      'id' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field' },
      'title' => {
        'type' => 'multi_field',
        'fields' => {
          'title' => { 'type' => 'string', 'sort' => 'multi_field' },
          'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
        }
      },
      'ingestType' => { 'enabled' => false },
      'ingestDate' => { 'enabled' => false },
      '_rev' => { 'enabled' => false },
    }
  },  #/collection
  'item' => {
    'date_detection' => false,
    'properties' => {
      '@id' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field' },
      'admin' => {
        'properties' => {
          'sourceResource' => {  #shadow_sort fields
            'properties' => {
              'title' => { 'type' => 'string', 'analyzer' => 'canonical_sort', 'null_value' => 'zzzzzzzz' },
            }
          },
          'valid_after_enrich' => { 'type' => 'boolean'},
          'validation_message' => { 'enabled' => 'false'},
          'ingestType' => { 'enabled' => false },
          'ingestDate' => { 'type' => 'date' },
          'contributingInstitution' => {
            'type' => 'string',
            'enabled' => false,
            'include_in_all' => false,
            'compound_fields' => ['dataProvider.not_analyzed','intermediateProvider.not_analyzed'],
            'facet' => true
          }
        }
      },
      'id' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field' },
      'sourceResource' => {
        'properties' => {
          'identifier' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field' },
          'collection' => {
            'properties' => {
              '@id' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
              'id' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
              'description' => { 'type' => 'string' },
              'title' => {
                'type' => 'multi_field',
                'fields' => {
                  'title' => { 'type' => 'string', 'sort' => 'multi_field' },
                  'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
                }
              }
            }
          },
          'contributor' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
          'creator' => { 'type' => 'string' },
          'date' => {
            'properties' => {
              'displayDate' =>  { 'type' => 'string', 'index' => 'not_analyzed'},
              'begin' => {
                'type' => 'multi_field',
                'fields' => {
                  'begin' => { 'type' => 'date', 'sort' => 'multi_field', 'null_value' => '-9999' },
                  'not_analyzed' => { 'type' => 'date', 'sort' => 'field', 'facet' => true }
                }
              },
              'end' => {
                'type' => 'multi_field',
                'fields' => {
                  'end' => { 'type' => 'date', 'sort' => 'multi_field', 'null_value' => '9999' },
                  'not_analyzed' => { 'type' => 'date', 'sort' => 'field', 'facet' => true }
                }
              }
            }
          },
          'description' => { 'type' => 'string' },
          'extent' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field' },
          'isPartOf' => { 'enabled' => false },
          'language' => {
            'properties' => {
              'name' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
              'iso639' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true }
            }
          },
          'format' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
          'publisher' => {
            'type' => 'multi_field',
            'fields' => {
              'publisher' => { 'type' => 'string' },
              'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'facet' => true }
            }
          },
          'rights' => { 'type' => 'string' },
          'relation' => { 'type' => 'string' },
          'spatial' => {
            'properties' => {
              'name' => {
                'type' => 'multi_field',
                'fields' => {
                  'name' => { 'type' => 'string', 'sort' => 'multi_field' },
                  'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
                }
              },
              'country' => {
                'type' => 'multi_field',
                'fields' => {
                  'country' => { 'type' => 'string', 'sort' => 'multi_field' },
                  'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
                }
              },
              'region' => {
                'type' => 'multi_field',
                'fields' => {
                  'region' => { 'type' => 'string', 'sort' => 'multi_field' },
                  'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
                }
              },
              'county' => {
                'type' => 'multi_field',
                'fields' => {
                  'county' => { 'type' => 'string', 'sort' => 'multi_field' },
                  'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
                }
              },
              'state' => {
                'type' => 'multi_field',
                'fields' => {
                  'state' => { 'type' => 'string', 'sort' => 'multi_field' },
                  'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
                }
              },
              'city' => {
                'type' => 'multi_field',
                'fields' => {
                  'city' => { 'type' => 'string', 'sort' => 'multi_field' },
                  'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
                }
              },
              'iso3166-2' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
              'coordinates' => { 'type' => 'geo_point', 'index' => 'not_analyzed', 'sort' => 'geo_distance', 'facet' => true }
            }
          },
          'specType' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
          'stateLocatedIn' => {
            'properties' => {
              'name' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
              'iso3166-2' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true }
            }
          },
          'subject' => {
            'properties' => {
              '@id' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
              '@type' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field' },
              'name' => {
                'type' => 'multi_field',
                'fields' => {
                  'name' => { 'type' => 'string', 'sort' => 'multi_field' },
                  'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
                }
              }
            }
          },
          'temporal' => {
            'properties' => {
              'begin' => {
                'type' => 'multi_field',
                'fields' => {
                  'begin' => { 'type' => 'date', 'sort' => 'multi_field', 'null_value' => '-9999' },
                  'not_analyzed' => { 'type' => 'date', 'sort' => 'field', 'facet' => true }
                }
              },
              'end' => {
                'type' => 'multi_field',
                'fields' => {
                  'end' => { 'type' => 'date', 'sort' => 'multi_field', 'null_value' => '9999' },
                  'not_analyzed' => { 'type' => 'date', 'sort' => 'field', 'facet' => true }
                }
              }

            }
          },
          'title' => { 'type' => 'string', 'sort' => 'shadow' },
          'type' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
        }
      },  #/sourceResource
      'dataProvider' => {
        'type' => 'multi_field',
        'fields' => {
          'dataProvider' => { 'type' => 'string', 'sort' => 'multi_field' },
          'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
        }
      },
      'hasView' => {
        'properties' => {
          '@id' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
          'format' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true },
          'rights' => { 'type' => 'string', 'index' => 'not_analyzed' },
          'edmRights' => {
            'type' => 'multi_field',
            'fields' => {
              'edmRights' => { 'type' => 'string', 'sort' => 'multi_field' },
              'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
            }
          }
        }
      },
      'intermediateProvider' => {
        'type' => 'multi_field',
        'fields' => {
          'intermediateProvider' => { 'type' => 'string', 'sort' => 'multi_field' },
          'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
        }
      },
      'isPartOf' => {
        'properties' => {
          '@id' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
          'name' => {
            'type' => 'multi_field',
            'fields' => {
              'name' => { 'type' => 'string', 'sort' => 'multi_field' },
              'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
            }
          }
        }
      },
      'isShownAt' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field' },
      'object' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field' },
      'provider' => {
        'properties' => {
          '@id' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'field', 'facet' => true },
          'name' => {
            'type' => 'multi_field',
            'fields' => {
              'name' => { 'type' => 'string', 'sort' => 'multi_field' },
              'not_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed', 'sort' => 'script', 'facet' => true }
            }
          }
        }
      },
      'rights' => { 'type' => 'string' },
      '@context' => { 'type' => 'object', 'enabled' => false },
      'originalRecord' => { 'type' => 'object', 'enabled' => false },
      'ingestType' => { 'enabled' => false },
      'ingestDate' => { 'enabled' => false },
      '_rev' => { 'enabled' => false },
    }
  }  #/item
}.freeze


MAP3_JSON_HASH = {
  :id=>"116d5aaf3d77a5d7c5a6c7a3e10c5afe",
  :@id=>"http://dp.la/api/items/116d5aaf3d77a5d7c5a6c7a3e10c5afe",
  :ingestType=>"item",
  :isShownAt=>"http://digitalcollections.nypl.org/items/510d47e3-57d2-a3d9-e040-e00a18064a99",
  :provider=>{
    :name=>"The New York Public Library",
    :@id=>"http://dp.la/api/contributor/nypl"
  },
  :ingestionSequence=>13,
  :@type=>"ore:Aggregation",
  :_id=>"nypl--510d47e3-57d2-a3d9-e040-e00a18064a99",
  :@context=>"http://dp.la/api/items/context",
  :dataProvider=>"Manuscripts and Archives Division. The New York Public Library",
  :admin=>{
    :validation_message=>nil,
    :valid_after_enrich=>true,
    :object_status=>1
  },
  :sourceResource=>{
    :subject=>[{:name=>"Lesbians"}, {:name=>"Gay activists"}],
    :type=>"image",
    :title=>"Stonewall Inn [2]",
    :description=>"Window of the Stonewall Bar N.Y. 1969. The other half of the graffiti was erased by the time Diana photographed it.",
    :rights=>"The New York Public Library is interested in learning more about items you've seen on our websites or elsewhere online. If you have any more information about an item or its copyright status, we want to hear from you. Please contact DigitalCollections@nypl.org with your contact information and a link to the relevant content.",
    :@id=>"http://dp.la/api/items/116d5aaf3d77a5d7c5a6c7a3e10c5afe#sourceResource",
    :creator=>["Davies, Diana (1938-)"],
    :collection=>{
      :title=>"Greenwich Village, New York City, 1969 September",
      :id=>"d0729324dd20555729dd5c9ba07e401d",
      :@id=>"http://dp.la/api/collections/d0729324dd20555729dd5c9ba07e401d"
    },
    :date=>{
      :displayDate=>"1969-1969",
      :end=>"1969",
      :begin=>"1969"
    },
    :relation=>"Greenwich Village, New York City, 1969 September",
    :stateLocatedIn=>[{:name=>"New York"}]
  },
  :object=>"http://images.nypl.org/index.php?id=1582254&t=t",
  :aggregatedCHO=>"#sourceResource",
  :ingestDate=>"2014-09-05T17:57:00.302842Z"
}
