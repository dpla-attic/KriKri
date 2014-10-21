require 'spec_helper'

describe Krikri::Harvester do
  it 'is a havester' do
    expect(subject).to be_a Krikri::Harvester
  end

  context 'with record_ids implemented' do
    before do
      described_class.send(:define_method, :record_ids) do
        [1, 2, 3, 4, 5]
      end
    end

    it 'knows its record count' do
      expect(subject.count).to eq 5
    end
  end
end
