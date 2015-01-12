
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

    context 'after first harvest' do
      it 'builds same record' do
        r = subject.records.first
        r.save
        expect(subject.records.first.local_name).to eq r.local_name
        expect(subject.records.first).to be == r
      end

      it 'idempotent reharvests' do
        subject.records.each(&:save)
        records = subject.records
        records_2 = subject.records
        loop do
          r1 = records.next
          r2 = records_2.next
          expect(r1).to be == r2
        end
      end
    end
  end

  it 'can get an individual record' do
    expect(harvester.get_record(harvester.record_ids.first))
      .to be_a Krikri::OriginalRecord
  end

  describe '#run' do
    it 'saves the OriginalRecords' do
      # TODO: Is this fragile? Should it change when original records have
      #   persistence?
      allow(harvester).to receive(:records)
        .and_return [double('Original Record 1'), double('Record 2')]

      harvester.records.each do |r|
        expect(r).to receive(:save).and_return(true)
      end

      harvester.run
    end
  end

  it_behaves_like 'a software agent',
    { uri: 'http://example.org/endpoint' },
    Krikri::HarvestJob
end
