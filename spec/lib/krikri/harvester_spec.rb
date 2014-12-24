require 'spec_helper'

describe Krikri::Harvester do

  # Our subject is an instance of a dummy class that mixes in
  # Krikri::Harvester.
  let(:klass) { Class.new }
  subject { klass.include(Krikri::Harvester).new }

  context 'with record_ids implemented' do
    before do
      allow(subject).to receive(:record_ids).and_return([1, 2, 3, 4, 5])
    end

    it 'knows its record count' do
      expect(subject.count).to eq 5
    end
  end

end
