
shared_examples 'an enrichment' do
  it 'is an enrichment' do
    expect(subject).to be_a Krikri::Enrichment
  end

  let(:record) { build(:aggregation) }

  describe '#list_fields' do
    let(:list) { subject.list_fields(record) }

    it 'generates a list of fields' do
      expect(list).to include(an_instance_of(Symbol), an_instance_of(Hash))
    end
  end

  describe '#enrich_field' do
    let(:field_chain) { [:aggregatedCHO, :creator, :providedLabel] }
    let(:klass) { record.aggregatedCHO.first.creator.first.class }
    let(:updated_value) { 'Christmas in Moominvalley' }
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
    xit 'runs enrichment over all fields' do
      expect(subject).to receive(:enrich_value)
    end
  end
end
