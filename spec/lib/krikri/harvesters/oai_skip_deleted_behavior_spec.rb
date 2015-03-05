require 'spec_helper'

describe Krikri::Harvesters::OAISkipDeletedBehavior do
  it_behaves_like 'a harvest behavior'

  subject { described_class.new(record, activity_uri) }
  let(:record) { build(:oai_dc_record) }
  let(:activity_uri) { double('activity URI') }

  describe '#process_record' do
    context 'with deleted record' do
      let(:record) { build(:oai_deleted_record) }

      it 'skips record' do
        expect(record).not_to receive(:save)
        subject.process_record
      end
    end

    it 'saves record' do
      expect(record).to receive(:save).with(activity_uri)
      subject.process_record
    end
  end
end
