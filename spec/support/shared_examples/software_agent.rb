
shared_examples 'a software agent' do |args, job_class|
  subject { described_class.new(args) }
  let(:agent_class) { described_class }

  it 'represents its agent name as the correct string, as a class' do
    expect(agent_class.agent_name)
      .to eq agent_class.to_s
  end

  it 'represents its agent name as the correct string, as an instance' do
    expect(subject.agent_name).to eq agent_class.to_s
  end

  describe '#enqueue' do
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
