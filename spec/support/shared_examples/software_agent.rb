
shared_examples 'a software agent' do |args|
  subject { args.nil? ? described_class.new : described_class.new(args) }
  let(:agent_class) { described_class }

  it 'represents its agent name as the correct string, as a class' do
    expect(agent_class.agent_name)
      .to eq agent_class.to_s
  end

  it 'represents its agent name as the correct string, as an instance' do
    expect(subject.agent_name).to eq agent_class.to_s
  end

  describe '.agent_name' do
    it { expect(agent_class.agent_name).to be_a String }
  end

  describe '.queue_name' do
    it { expect(agent_class.queue_name).to respond_to :to_s }

    it 'is lowercase' do
      expect(agent_class.queue_name).to eq agent_class.queue_name.downcase
    end
  end

  describe '#agent_name' do
    it { expect(subject.agent_name).to be_a String }
  end

  describe '#run' do
    it 'accepts one or no arguments' do
      expect(subject.method(:run).arity).to satisfy { |v| v == -1 || v == 0 }
    end
  end

  describe '#enqueue' do
    let(:queue_name) { described_class.queue_name.to_s }

    it 'accepts options hash as first arg' do
      expect(agent_class.enqueue({})).to be true
    end

    it 'accepts options hash as second arg' do
      expect(agent_class.enqueue('my_queue', {})).to be true
    end

    it 'throws an error if too many args are given' do
      expect { agent_class.enqueue('my_queue', {}, :abc) }
        .to raise_error ArgumentError
    end

    it 'throws an error if second arg is not options hash' do
      expect { agent_class.enqueue(:my_queue, :abc) }
        .to raise_error ArgumentError
    end

    it 'enqueues a job' do
      expect { agent_class.enqueue(args) }
        .to change { Resque.size(queue_name) }.by(1)
    end

    it 'creates a new activity when it enqueues a job' do
      expect { agent_class.enqueue(args) }
        .to change { Krikri::Activity.count }.by(1)
    end

    it 'logs queue creation' do
      expect(Rails.logger).to receive(:info).exactly(2).times
      agent_class.enqueue(args)
    end
  end
end
