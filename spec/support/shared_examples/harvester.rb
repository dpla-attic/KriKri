shared_examples 'a harvester' do
  opts = { uri: 'http://example.org/endpoint' }
  it_behaves_like 'a software agent', opts

  let(:harvester) { subject }
  let(:name) { :test_harvester }

  it { expect(described_class.queue_name.to_s).to eq 'harvest' }

  it 'is a harvester' do
    expect(harvester).to be_a Krikri::Harvester
  end

  it 'raises an error if no uri is given' do
    expect { described_class.new }.to raise_error KeyError
  end

  it 'is in registry' do
    key = described_class.key
    expect(Krikri::Harvester::Registry.get(key)).to eq described_class
  end

  xit 'has a record count' do
    expect(harvester.count).to be_a Integer
  end

  describe '.key' do
    it { expect(described_class.key).to be_a Symbol }
  end
  
  describe '#record_ids' do
    it 'can get its record ids' do
      expect(harvester.record_ids).to be_a Enumerator
    end

    it 'gives ids as strings' do
      harvester.record_ids.each { |i| expect(i).to be_a String }
    end
  end

  describe 'local_name creation' do
    before { harvester.name = name }

    let(:gen_id) { 'my_id' }

    it 'mints md5 identifiers with #records' do
      expect(Krikri::Md5Minter).to receive(:create)
        .with(harvester.record_ids.first,
              harvester.name)
        .and_return(gen_id)

      expect(harvester.records.first.local_name).to eq gen_id
    end

    it 'mints md5 identifiers with #get_record' do
      expect(Krikri::Md5Minter).to receive(:create)
        .with(harvester.record_ids.first, harvester.name)
        .and_return(gen_id)
      expect(harvester.get_record(harvester.record_ids.first).local_name)
        .to eq gen_id
    end
  end

  describe '.expected_opts' do
    it 'returns a hash with key and options' do
      expect(described_class.expected_opts)
        .to match a_hash_including(:key => (an_instance_of(Symbol)),
                                   :opts => an_instance_of(Hash))
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

  describe '#get_record' do
    it 'gets an individual record' do
      expect(harvester.get_record(harvester.record_ids.first))
        .to be_a Krikri::OriginalRecord
    end

    it 'escapes identifiers' do
      expect(subject.records.first.local_name).not_to include(':')
    end

    it 'returns a normalized record' do
      expect(harvester.get_record(harvester.record_ids.first).content)
        .to eq harvester.records.first.content
    end
  end

  describe '#run' do
    before do
      allow(harvester).to receive(:records)
                           .and_return [double('Original Record 1'),
                                        double('Record 2')]
    end

    let(:activity_uri) { RDF::URI('http://example.org/prov/activity/1') }

    it 'processes the OriginalRecords' do
      harvester.records.each do |r|
        expect(harvester).to receive(:process_record).with(r, activity_uri)
                             .and_return(true)
      end
      harvester.run(activity_uri)
    end
  end

  describe '#name' do
    it 'has name accessors' do
      harvester.name = name
      expect(subject).to have_attributes(:name => name)
    end
  end

  it_behaves_like 'a software agent', uri: 'http://example.org/endpoint'
end
