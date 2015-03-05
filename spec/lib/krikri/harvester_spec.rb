require 'spec_helper'

describe Krikri::Harvester do

  # Our subject is an instance of a dummy class that mixes in
  # Krikri::Harvester.
  let(:klass) { class DummyHarvester; end; DummyHarvester }
  subject { klass.include(Krikri::Harvester).new(:uri => 'urn:fake_uri') }

  context 'with record_ids implemented' do
    before do
      allow(subject).to receive(:record_ids).and_return([1, 2, 3, 4, 5])
    end

    it 'knows its record count' do
      expect(subject.count).to eq 5
    end
  end

  describe '.enqueue' do
    it 'defaults to HarvestJob' do
      subject.class.enqueue({})
      expect(Krikri::Activity.all.map(&:agent)).to include klass.to_s
    end
  end

  describe '#run' do
    let(:records) { [double('record'), double('record2')] }

    before do
      allow(subject).to receive(:records).and_return(records)
    end

    context 'with non-default behavior' do
      subject { klass.include(Krikri::Harvester).new(opts) }
      let(:opts) do
        { :uri => 'urn:fake_uri',
          :harvest_behavior => 'Krikri::Harvesters::OAISkipDeletedBehavior' }
      end

      it 'sends record to behavior for processing' do
        activity_uri = double('activity uri')
        records.each do |rec|
          expect(Krikri::Harvesters::OAISkipDeletedBehavior)
            .to receive(:process_record).with(rec, activity_uri).and_return(true)
        end
        subject.run(activity_uri)
      end
    end

    context 'when behavior fails' do
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
