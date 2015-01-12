require 'spec_helper'

describe Krikri::MappingJob do
  include_context 'clear repository'

  let(:record) { build(:krikri_original_record) }

  it_behaves_like 'a job', :krikri_mapping_activity do
    before do
      expect(Krikri::Mapper).to receive(:map)
        .and_return([DPLA::MAP::Aggregation.new])
    end
  end

  context 'with matching records' do
    let(:activity) { create(:krikri_activity) }
    let(:opts) do
      { name: 'test_map', generator_uri: activity.rdf_subject.to_s }.to_json
    end

    let(:mapping_activity) { create(:krikri_mapping_activity, opts: opts) }
    let(:test_mapper) { instance_double(Krikri::Mapping) }

    before do
      record.save(activity.rdf_subject)
      allow(Krikri::Mapper::Registry).to receive(:get).with(:test_map)
        .and_return(test_mapper)
    end

    it 'calls the mapper with record' do
      expect(test_mapper).to receive(:process_record).with(record)
        .and_return(DPLA::MAP::Aggregation.new)
      described_class.perform(mapping_activity.id)
    end
  end
end
