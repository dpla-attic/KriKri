require 'spec_helper'

describe Krikri::Activity do

  subject { described_class.new(agent_class.new) }
  let(:agent_class) { Class.new { extend Krikri::SoftwareAgent } }

  describe '#agent' do
    it 'has an agent' do
      expect(subject.agent).to be_a agent_class
    end
  end

  describe '#start_time' do
    before do
      subject.set_start_time
    end

    it 'marks start time' do
      expect(subject.start_time).to be_a DateTime
    end
  end

  describe 'end_time' do
    it 'raises an error if not started' do
      expect { subject.set_end_time }.to raise_error
    end

    context 'with start time' do
      before do
        subject.set_start_time
        subject.set_end_time
      end

      it 'marks end time' do
        subject.set_start_time
        expect(subject.end_time).to be_a DateTime
      end
    end
  end

  describe 'running activities' do
    subject do
      described_class.new(agent_class) {}
    end

    it 'runs block passed in' do
      expect { |b| described_class.new(agent_class, &b) }.to yield_control
    end

    it 'sets start time' do
      expect(subject.start_time).to be_within(1.second).of(DateTime.now)
    end

    it 'sets end time' do
      expect(subject.end_time).to be_within(1.second).of(DateTime.now)
    end
  end

end
