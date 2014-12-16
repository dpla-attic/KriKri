require 'spec_helper'

describe Krikri::HarvestJob do
  let(:activity) { create(:krikri_activity) }
  describe '#perform' do
    before do
      expect_any_instance_of(Krikri::Harvester)
        .to receive(:run)
        .and_return(true)
    end
    it 'runs a harvest' do
      expect { Krikri::HarvestJob.perform(activity.id) }.not_to raise_error
    end
    it 'causes activity timestamps to be correctly modified' do
      Krikri::HarvestJob.perform(activity.id)
      activity.reload
      expect(activity.end_time).to be_within(1.second).of(DateTime.now)
    end
  end
end
