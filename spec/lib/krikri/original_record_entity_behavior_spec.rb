require 'spec_helper'

describe Krikri::OriginalRecordEntityBehavior do

  before do
    # @see aggregation_entity_behavior_spec.rb
    DatabaseCleaner.clean_with(:truncation)
  end

  describe '#entities' do

    let(:orig_record_uri) { double('record uri') }
    let(:orig_record_double) { instance_double(Krikri::OriginalRecord) }
    let(:activity) { create(:krikri_harvest_activity) }

    it 'requests only validated entities by default' do
      expect(activity).to receive(:entity_uris)
        .with(false)
        .and_return([orig_record_uri])
      activity.entities
    end
  end
end
