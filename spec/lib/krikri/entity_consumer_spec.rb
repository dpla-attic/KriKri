require 'spec_helper'

describe Krikri::EntityConsumer do

  before(:all) do
    DatabaseCleaner.clean_with(:truncation)
    create(:krikri_harvest_activity)
    create(:krikri_mapping_activity)
  end

  context 'as a mapper agent' do
    let(:generator_uri) { Krikri::Activity.base_uri / 2 }
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
