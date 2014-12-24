require 'spec_helper'

describe Krikri::SoftwareAgent do

  # Use OAIHarvester as a representative SoftwareAgent ...

  it 'represents its agent name as the correct string, as a class' do
    expect(Krikri::Harvesters::OAIHarvester.agent_name)
      .to eq('Krikri::Harvesters::OAIHarvester')
  end

  it 'represents its agent name as the correct string, as an instance' do
    h = Krikri::Harvesters::OAIHarvester.new({endpoint: 'http://example.org/'})
    expect(h.agent_name).to eq('Krikri::Harvesters::OAIHarvester')
  end

  describe '#enqueue' do
    let(:args) do
      { endpoint: 'http://example.org/endpoint', metadata_prefix: 'mods' }
    end
    # Use these classes as representatives for the tests
    let(:agent_class) { Krikri::Harvesters::OAIHarvester }
    let(:job_class) { Krikri::HarvestJob }
    let(:queue_name) { job_class.instance_variable_get('@queue') }
    before do
      Resque.remove_queue(queue_name)
      Krikri::Activity.delete_all
    end
    it 'enqueues a job' do
      agent_class.enqueue(job_class, args)
      expect(Resque.size(queue_name)).to eq(1)
    end
    it 'creates a new activity when it enqueues a job' do
      agent_class.enqueue(job_class, args)
      expect(Krikri::Activity.count).to eq(1)
    end
  end

end
