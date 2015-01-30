require 'spec_helper'

describe Krikri::Mapping do

  let(:record) { build(:oai_dc_record) }

  describe '#process_record' do
    it 'creates a DPLA::MAP record' do
      expect(subject.process_record(record)).to be_a DPLA::MAP::Aggregation
    end

    it 'builds target class set in initializer' do
      klass = DPLA::MAP::SourceResource
      new_mapping = Krikri::Mapping.new(klass)
      expect(new_mapping.process_record(record)).to be_a klass
    end

    context 'with static properties' do
      before do
        subject.rightsStatement value
      end

      subject { described_class.new }
      let(:value) { 'Rights Reserved; Moomin Access Only' }

      it 'sets value' do
        expect_any_instance_of(DPLA::MAP::Aggregation)
          .to receive(:rightsStatement=).with(value)
        subject.process_record(record)
      end
    end
  end
end
