require 'spec_helper'

describe Krikri::Harvesters::BasicSaveBehavior do
  it_behaves_like 'a harvest behavior'

  subject { described_class.new(record, activity_uri) }
  let(:record) { double('record') }
  let(:activity_uri) { double('activity URI') }

  describe '#process_record' do
    it 'calls save with activity_uri on the record' do
      expect(record).to receive(:save).with(activity_uri)
      subject.process_record
    end
  end
end
