require 'spec_helper'

describe Krikri::AggregationEntityBehavior do

  describe '#generated_entities' do

    let(:mapping_activity_uri) do
      (RDF::URI(Krikri::Settings['marmotta']['ldp']) /
      Krikri::Settings['prov']['activity'] / '2').to_s
    end
    let(:agg_record_double) { instance_double(DPLA::MAP::Aggregation) }
    let(:activity) { build(:krikri_mapping_activity) }

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
