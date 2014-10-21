
shared_examples 'a harvester' do

  let(:harvester) { subject || described_class.new }

  it 'is a harvester' do
    expect(harvester).to be_a Krikri::Harvester
  end

  xit 'has a record count' do
    expect(harvester.count).to be_a Integer
  end

  describe '#record_ids' do
    it 'can get its record ids' do
      expect(harvester.record_ids).to be_a Enumerator
    end

    it 'gives ids as strings' do
      harvester.record_ids.each { |i| expect(i).to be_a String }
    end
  end

  describe '#records' do
    it 'returns a record enumerator' do
      expect(subject.records).to be_a Enumerator
    end

    it 'returns OriginalRecords' do
      subject.records.each { |r| expect(r).to be_a Krikri::OriginalRecord }
    end
  end

  it 'can get an individual record' do
    expect(harvester.get_record(harvester.record_ids.first))
      .to be_a Krikri::OriginalRecord
  end

  describe '#run' do
    it 'runs as an Activity' do
      expect(harvester.run).to be_a Krikri::Activity
    end

    it 'saves the OriginalRecords' do
      # TODO: Is this fragile? Should it change when original records have
      #   persistence?
      harvester.stub(:records)
        .and_return [double('Original Record 1'), double('Record 2')]

      harvester.records.each do |r|
        expect(r).to receive(:save).and_return(true)
      end

      harvester.run
    end
  end

  it_behaves_like 'a software agent'

end
