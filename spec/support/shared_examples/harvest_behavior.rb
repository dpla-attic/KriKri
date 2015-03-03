
shared_examples 'a harvest behavior' do
  subject { described_class.new(record, activity_uri) }
  let(:record) { double('record') }
  let(:activity_uri) { double('activity URI') }

  it { is_expected.to have_attributes(:record => record) }
  it { is_expected.to have_attributes(:activity_uri => activity_uri) }

  describe '.process_record' do
    it 'passes args and call to instance' do
      instance = double('behavior instance')

      expect(described_class).to receive(:new).with(record, activity_uri)
                                  .and_return(instance)
      expect(instance).to receive(:process_record)

      described_class.process_record(record, activity_uri)
    end
  end
end
