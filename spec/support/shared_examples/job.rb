
shared_examples 'a job' do |agent_class|
  let(:activity) { create(:krikri_activity) }

  it 'runs a harvest' do
    expect { described_class.perform(activity.id) }.not_to raise_error
  end

  it 'causes activity timestamps to be correctly modified' do
    described_class.perform(activity.id)
    activity.reload
    expect(activity.end_time).to be_within(1.second).of(DateTime.now)
  end
end
