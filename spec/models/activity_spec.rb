require 'spec_helper'
require 'timecop'

##
# Custom matcher that verifies whether the period represented by the start
# and end timestamps of the given model is close enough to the given duration.
RSpec::Matchers.define :have_duration_of do |duration|
  match do |actual|
    real_dur = actual.end_time - actual.start_time
    (real_dur - duration).abs < 0.1
  end
end

describe Krikri::Activity, type: :model do
  subject { create(:krikri_activity) }

  describe `.base_uri` do
    it 'returns an RDF::URI' do
      expect(described_class.base_uri).to be_a RDF::URI
    end
  end

  describe `.from_uri` do
    it 'initializes from RDF::URI' do
      expect(described_class.from_uri(subject.rdf_subject)).to eq subject
    end

    it 'initializes from string containing uri' do
      expect(described_class.from_uri(subject.rdf_subject.to_s)).to eq subject
    end

    it 'raises error for inapproprate uri' do
      bad_uri = "http://example.com/nonsense/#{subject.id}"

      expect { described_class.from_uri(bad_uri) }
        .to raise_error "Cannot find #{described_class} from " \
                        "URI: #{bad_uri}; the requested uri does not match " \
                        "#{described_class.base_uri}"
    end

    it 'raises error for wrong id' do
      bad_uri = subject.rdf_subject.to_s.gsub(subject.id.to_s, '1001')

      expect { described_class.from_uri(bad_uri) }
        .to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#save' do
    subject { build(:krikri_activity_with_long_opts) }

    it 'saves long :opts values successfully' do
      expect { subject.save }.not_to raise_error
    end
  end

  describe '#rdf_subject' do
    it 'is a URI' do
      expect(subject.rdf_subject).to be_a RDF::URI
    end

    it 'uses #id as local name ' do
      expect(subject.rdf_subject.to_s).to end_with subject.id.to_s
    end
  end

  describe '#to_term' do
    it 'gives the subject' do
      expect(subject.to_term).to eq subject.rdf_subject
    end
  end

  describe '#to_s' do
    it 'outputs the object properties' do
      expect(subject.to_s).to eq subject.inspect.to_s
    end
  end

  describe '#start_time' do
    before do
      subject.set_start_time
    end

    it 'marks start time' do
      expect(subject.start_time).to be_a ActiveSupport::TimeWithZone
    end
  end

  describe '#end_time' do
    it 'raises an error if not started' do
      expect { subject.set_end_time }
        .to raise_error 'Start time must exist and be before now to set an ' \
                        'end time'
    end
  end

  describe '#ended?' do
    context 'before completion' do
      it 'returns false' do
        expect(subject).not_to be_ended
      end
    end

    context 'while running' do
      before { subject.set_start_time }

      it 'returns false' do
        expect(subject).not_to be_ended
      end
    end

    context 'after completion' do
      before do
        subject.set_start_time
        subject.set_end_time
      end

      it 'returns true' do
        expect(subject).to be_ended
      end
    end
  end

  describe '#run' do
    it 'runs the given block' do
      expect { |b| subject.run(&b) }
        .to yield_with_args(subject.agent_instance, subject.rdf_subject)
    end

    it 'sets start and end times when running a block' do
      duration = 30     # seconds
      subject.run { Timecop.travel(duration) }
      Timecop.return    # come back to the present for future tests
      expect(subject).to have_duration_of(duration)
    end

    it 'logs start and finish' do
      expect(Rails.logger).to receive(:info).exactly(2).times
      subject.run { }
    end

    context 'after first run' do
      before do
        subject.run { }
      end

      it 'sets end_time to nil before running' do
        subject.run { expect(subject.end_time).to be_nil }
      end
    end

    context 'with error' do
      let(:error) { StandardError.new('my error') }

      it 'logs errors' do
        message = "Error performing Activity: #{subject.id}\nmy error"
        expect(Rails.logger).to receive(:error).with(start_with(message))
        begin
          subject.run { raise error }
        rescue
        end
      end

      it 'rethrows error' do
        expect { subject.run { raise error } }
          .to raise_error StandardError
      end

      it 'sets end time' do
        begin
          subject.run { raise error }
        rescue
        end
        expect(subject.end_time).to be_within(1.second).of(Time.now)
      end
    end
  end

  describe '#agent_instance' do
    it 'returns an instance of the agent class' do
      expect(subject.agent_instance)
        .to be_an_instance_of(subject.agent.constantize)
    end

    it 'returns the same instance for successive calls' do
      expect(subject.agent_instance).to be subject.agent_instance
    end
  end

  describe '#parsed_opts' do
    it 'is a hash of opts' do
      expect(subject.parsed_opts).to be_a Hash
    end

    it 'has symbolized keys' do
      subject.parsed_opts.keys.each do |k|
        expect(k).to be_a Symbol
      end
    end
  end

  describe '#entity_uris' do
    include_context 'provenance queries'
    include_context 'entities query'
    # See spec/factories/krikri_activities.rb
    # generator_uri is the URI of the harvest activity
    # generator_uri matches what Krikri::Activity will construct as the
    # uri, given its value of #rdf_subject, in #aggregations_as_json
    # See 'provenance queries' shared context.  
    let(:generator_uri) { subject.rdf_subject }

    it 'requests validated records by default' do
      expect(Krikri::ProvenanceQueryClient)
        .to receive(:find_by_activity)
        .with(RDF::URI(generator_uri), false).and_return(query)
      subject.entity_uris
    end

    it 'requests invalidated records if specifically requested' do
      expect(Krikri::ProvenanceQueryClient)
        .to receive(:find_by_activity)
        .with(RDF::URI(generator_uri), true).and_return(query)
      subject.entity_uris(true)
    end

    it 'enumerates generated entity URIs' do
      # 'result uri' is what the mocked query solution's record should contain.
      expect(subject.entity_uris.first).to match 'result uri'
    end
  end
end
