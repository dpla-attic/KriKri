require 'spec_helper'

describe Krikri::EntityConsumer do
  before(:all) do
    DatabaseCleaner.clean_with(:truncation)
    create(:krikri_harvest_activity)
    create(:krikri_mapping_activity)
  end

  subject { DummyAgent.new }
  let(:generator_uri) { Krikri::Activity.base_uri / 2 }

  before  { class DummyAgent; include Krikri::EntityConsumer; end }
  after   { Object.send(:remove_const, :DummyAgent) }

  describe 'deprecated interface' do
    it 'sets the activity' do
      expect { subject.assign_generator_activity!(generator_uri: generator_uri) }
        .to change { subject.generator_activity }
             .to Krikri::Activity.from_uri(generator_uri)
    end

    it 'activity defaults to nil' do
      expect(subject.generator_activity).to be_nil
    end

    it 'integrates with new interface' do
      expect { subject.assign_generator_activity!(generator_uri: generator_uri) }
        .to change { subject.entity_source }
             .to Krikri::Activity.from_uri(generator_uri)
    end
  end

  describe '#entities' do
    it 'is empty when no source is available' do
      expect(subject.entities).to be_empty
    end
  end

  describe '#entity_source' do
    it 'is nil by default' do
      expect(subject.entities).to be_empty
    end
  end

  context 'as a mapper agent' do
    let(:opts) { { name: :agent_map, generator_uri: generator_uri } }
    let(:mapper_agent) { Krikri::Mapper::Agent.new(opts) }

    describe '#assign_generator_activity!' do
      it 'sets the generator activity from the generator_uri parameter' do
        expect(mapper_agent.generator_activity)
          .to respond_to(:entities)
      end
    end
  end
end
