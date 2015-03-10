require 'spec_helper'

describe Krikri::EntityConsumer do

  before(:all) do
    create(:krikri_harvest_activity)
    create(:krikri_mapping_activity)
  end

  context 'as a mapper agent' do
    let(:generator_uri) do
      (RDF::URI(Krikri::Settings['marmotta']['ldp']) /
      Krikri::Settings['prov']['activity'] / '2').to_s
    end
    let(:opts) do
      {name: :agent_map, generator_uri: generator_uri}
    end
    let(:mapper_agent) { Krikri::Mapper::Agent.new(opts) }

    describe '#set_generator_activity!' do
      it 'sets the generator activity from the generator_uri parameter' do
        expect(mapper_agent.generator_activity)
          .to respond_to(:generated_entities)
      end
    end

  end

end
