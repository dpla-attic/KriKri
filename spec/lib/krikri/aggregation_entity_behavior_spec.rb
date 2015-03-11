require 'spec_helper'

describe Krikri::AggregationEntityBehavior do

  before do
    # The harvest activity is the activity that generated the entities upon
    # which the mapping activity below has acted.  I suppose we could mock the
    # call that will happen to EntityConsumer#set_generator_activity when
    # Krikri::Mapper::Agent is instantiated, but that seems like jumping
    # through more hoops and making this less comprehensible than it is now.
    DatabaseCleaner.clean_with(:truncation)
    create(:krikri_harvest_activity)
  end

  describe '#generated_entities' do

    let(:mapping_activity_uri) do
      (RDF::URI(Krikri::Settings['marmotta']['ldp']) /
      Krikri::Settings['prov']['activity'] / '2').to_s
    end
    let(:agg_record_double) { instance_double(DPLA::MAP::Aggregation) }
    let(:activity) { create(:krikri_mapping_activity) }

    it 'enumerates generated entities' do
      allow(activity).to receive(:generated_entity_uris)
        .and_return([mapping_activity_uri])
      allow(DPLA::MAP::Aggregation).to receive(:new)
        .with(mapping_activity_uri)
        .and_return(agg_record_double)
      # Circumvent Marmotta request with #get call in
      # AggregationEntityBehavior#generated_entities
      allow(agg_record_double).to receive(:get).and_return(true)
      agg = activity.generated_entities.first
      # Just so it's clear, this just proves that the code in
      # AggregationEntityBehavior#generated_entities was executed, not that
      # what's coming back from Marmotta is correct.
      expect(agg).to eq(agg_record_double)
    end
  end
end
