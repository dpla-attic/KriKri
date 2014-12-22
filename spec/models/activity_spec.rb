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

  describe 'start_time' do
    before do
      subject.set_start_time
    end

    it 'marks start time' do
      expect(subject.start_time).to be_a ActiveSupport::TimeWithZone
    end
  end

  describe 'end_time' do
    it 'raises an error if not started' do
      expect { subject.set_end_time }.to raise_error
    end
  end

  describe '#run' do
    it 'runs the given block' do
      expect { |b| subject.run(&b) }.to yield_control
    end
    it 'sets start and end times when running a block' do
      duration = 30     # seconds
      subject.run { Timecop.travel(duration) }
      Timecop.return    # come back to the present for future tests
      expect(subject).to have_duration_of(duration)
    end
  end

end
