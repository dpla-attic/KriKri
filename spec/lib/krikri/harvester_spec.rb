require 'spec_helper'

describe Krikri::Harvester do

  # Our subject is an instance of a dummy class that mixes in
  # Krikri::Harvester.
  let(:klass) { Class.new }
  subject { klass.include(Krikri::Harvester).new(:uri => 'urn:fake_uri') }

  context 'with record_ids implemented' do
    before do
      allow(subject).to receive(:record_ids).and_return([1, 2, 3, 4, 5])
    end

    it 'knows its record count' do
      expect(subject.count).to eq 5
    end
  end

  describe '#run' do
    let(:records) { [double, double] }

    before do
      allow(subject).to receive(:records).and_return(records)
    end

    context 'when save fails' do
      it 'logs error' do
        records.each do |rec|
          allow(rec).to receive(:save)
                         .and_raise(StandardError.new('my message'))
          allow(rec).to receive(:content).and_return 'content'
        end
        message =
          "Error harvesting record:\ncontent\n\twith message:\nmy message"
        expect(Rails.logger).to receive(:error).with(message).twice
        subject.run
      end
    end
  end
end
