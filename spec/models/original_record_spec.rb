require 'spec_helper'

describe Krikri::OriginalRecord do

  shared_context 'serializations' do
    it 'has a string format' do
      expect(subject.to_s).to be_a String
    end

    it 'string format matches input' do
      expect(subject.to_s).to eq record.to_s
    end
  end

  subject { described_class.new(record) }

  it 'raises an error if not passed a file or string' do
    expect { described_class.new([1, 2, 3]) }.to raise_error ArgumentError
  end

  context 'with string input' do
    let(:record) { '<record><title>Comet in Moominland</title></record>' }

    include_context 'serializations'
  end

end
