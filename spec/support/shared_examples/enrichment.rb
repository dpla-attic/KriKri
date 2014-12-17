
shared_examples 'an enrichment' do
  it 'is an enrichment' do
    expect(subject).to be_a Krikri::Enrichment
  end

  let(:record) { build(:aggregation) }
  let(:updated_value) { 'Christmas in Moominvalley' }

  describe '#list_fields' do
    let(:list) { subject.list_fields(record) }

    it 'generates a list of fields' do
      expect(list).to include(an_instance_of(Symbol), an_instance_of(Hash))
    end
  end

  describe '#enrich_field' do
    let(:field_chain) { [:aggregatedCHO, :creator, :providedLabel] }
    let(:klass) { record.aggregatedCHO.first.creator.first.class }
    let(:enriched) { subject.enrich_field(record, field_chain) }

    before do
      allow(subject).to receive(:enrich_value).and_return(updated_value)
    end

    it 'updates value with enriched version' do
      expect(enriched.aggregatedCHO.first.creator.first.providedLabel)
        .to eq [updated_value]
    end

    context 'when targeted value is empty' do
      before do
        enriched.aggregatedCHO.first.creator.first.providedLabel = nil
      end

      it 'passes over value' do
        expect(enriched.aggregatedCHO.first.creator.first.providedLabel)
          .to eq []
      end
    end

    context 'with multiple values' do
      before do
        new_creator = klass.new
        new_creator.providedLabel = 'old value'
        record.aggregatedCHO.first.creator << new_creator
        record.aggregatedCHO.first.creator << 'literal value'
      end

      it 'retains literal values' do
        expect(enriched.aggregatedCHO.first.creator)
          .to contain_exactly('literal value',
                              an_instance_of(klass),
                              an_instance_of(klass))
      end

      it 'updates values with enriched versions' do
        creators = enriched.aggregatedCHO.first.creator
          .select { |o| o.kind_of?(klass) }
        creators.each { |val| expect(val.providedLabel).to eq [updated_value] }
      end

      context 'when node is missing property' do
        before do
          enriched.aggregatedCHO.first.creator << ActiveTriples::Resource.new
        end

        it 'leaves node unaltered'
      end
    end
  end

  describe '#enrich_all' do
    it 'runs enrichment over all fields' do
      expect(subject).to receive(:enrich_field)
        .exactly(subject.list_fields(record).count).times
      subject.enrich_all(record)
    end

    it 'sets fields to new value' do
      allow(subject).to receive(:enrich_value).and_return(updated_value)
      subject.enrich_all(record)
      record.class.properties.each do |prop, _|
        expect(record.send(prop)).to eq [updated_value]
      end
    end

    it 'returns the record' do
      expect(subject.enrich_all(record)).to eq record
    end
  end

  describe 'enrich' do
    it 'defaults to all fields' do
      expect(subject).to receive(:enrich_all)
      subject.enrich(record)
    end

    it 'accepts :all for fields' do
      expect(subject).to receive(:enrich_all)
      subject.enrich(record, :all)
    end

    it 'is a copy of the input record' do
      expect(subject.enrich(record)).to eq record
      expect(subject.enrich(record)).not_to eql record
    end

    context 'with field arguments' do
      let(:simple_field) { :preview }
      let(:deep_field)   { {:aggregatedCHO => {:creator => :providedLabel}} }
      let(:deep_field_2) { {:aggregatedCHO => {:spatial => :parentFeature}} }

      let(:deep_field_chain)   { [:aggregatedCHO, :creator, :providedLabel] }
      let(:deep_field_2_chain)   { [:aggregatedCHO, :spatial, :parentFeature] }

      it 'runs against simple fields' do
        expect(subject).to receive(:enrich_field).with(record, [simple_field])
        subject.enrich(record, simple_field)
      end

      it 'runs against deep fields' do
        expect(subject).to receive(:enrich_field).with(record, deep_field_chain)
        subject.enrich(record, deep_field)
      end

      it 'runs against multiple fields' do
        expect(subject).to receive(:enrich_field).with(record, [simple_field])
        expect(subject).to receive(:enrich_field).with(record, deep_field_chain)
        expect(subject).to receive(:enrich_field).with(record, deep_field_2_chain)
        subject.enrich(record, simple_field, deep_field, deep_field_2)
      end

      it 'is a copy of the input record' do
        expect(subject.enrich(record, simple_field, deep_field, deep_field_2))
          .to eq record
        expect(subject.enrich(record, simple_field, deep_field, deep_field_2))
          .not_to eql record
      end
    end
  end
end
