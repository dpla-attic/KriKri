shared_context 'with record' do
  let(:record) { build(:aggregation) }
end

shared_examples 'an enrichment' do
  include_context 'with record'

  it 'is an enrichment' do
    expect(subject).to be_a Krikri::Enrichment
  end

  it 'is implemented' do
    expect(subject).to respond_to :enrich_value
  end

  describe '#list_fields' do
    let(:list) { subject.list_fields(record) }

    it 'generates a list of fields' do
      expect(list).to include(an_instance_of(Symbol), an_instance_of(Hash))
    end
  end

  describe '#enrich' do
    before { allow(subject).to receive(:enrich_value).and_return(new_value) }

    let(:new_value) { ['Christmas in Moominvalley'] }
    let(:args) do
      subject.class.instance_method(:enrich).arity > 1 ? enrich_args : [record]
    end

    it 'returns a record eql to the input record' do
      expect(subject.enrich(*args)).to eq record
    end

    it 'copies the input record' do
      expect(subject.enrich(*args)).not_to eql record
    end

    it 'does not change the record object passed in' do
      expect { subject.enrich(*args) }.not_to change { record }
    end
  end
end

shared_examples 'a generic enrichment' do
  it_behaves_like 'an enrichment'
  include_context 'with record'

  let(:enrich_args) do
    [record, [{ :sourceResource => :title }], [{ :sourceResource => :creator }]]
  end

  describe '#enrich' do
    before do
      allow(subject).to receive(:enrich_value).and_return(new_value)
    end

    shared_examples 'multiple input fields' do
      before do
        record.sourceResource.first.spatial.first.name = 'NY'
        enrich_args[1] << { :sourceResource => { :spatial => :name } }
      end

      let(:input_values) do
        [record.sourceResource.map(&:title).flatten,
         record.sourceResource.map { |sr| sr.spatial.map(&:name) }.flatten]
      end

      it 'enriches with values for input fields' do
        expect(subject).to receive(:enrich_value).with(input_values)
        subject.enrich(*enrich_args)
      end
    end

    context 'with single output field' do
      include_examples 'multiple input fields'

      let(:new_value) { ['snufkin'] }

      it 'enriches targeted field' do
        subject.enrich(*enrich_args).sourceResource.map do |cho|
          expect(cho.creator).to eq new_value
        end
      end
    end

    context 'with multiple output fields' do
      include_examples 'multiple input fields'

      before do
        enrich_args[2] << { :sourceResource => :spatial }
      end

      let(:new_value) { [['snufkin'], ['moominvalley']] }

      it 'enriches targeted fields' do
        subject.enrich(*enrich_args).sourceResource.map do |cho|
          expect(cho.creator).to eq new_value.first
          expect(cho.spatial).to eq new_value[1]
        end
      end
    end
  end
end

shared_examples 'a field enrichment' do
  it_behaves_like 'an enrichment'
  include_context 'with record'

  let(:updated_value) { 'Christmas in Moominvalley' }

  describe '#enrich_field' do
    let(:field_chain) { [:sourceResource, :creator, :providedLabel] }
    let(:klass) { record.sourceResource.first.creator.first.class }
    let(:enriched) { subject.enrich_field(record, field_chain) }

    before do
      allow(subject).to receive(:enrich_value).and_return(updated_value)
    end

    it 'updates value with enriched version' do
      expect(enriched.sourceResource.first.creator.first.providedLabel)
        .to eq [updated_value]
    end

    context 'when targeted value is empty' do
      before do
        enriched.sourceResource.first.creator.first.providedLabel = nil
      end

      it 'passes over value' do
        expect(enriched.sourceResource.first.creator.first.providedLabel)
          .to eq []
      end
    end

    context 'with multiple values' do
      before do
        new_creator = klass.new
        new_creator.providedLabel = 'old value'
        record.sourceResource.first.creator << new_creator
        record.sourceResource.first.creator << 'literal value'
      end

      it 'retains literal values' do
        expect(enriched.sourceResource.first.creator)
          .to contain_exactly('literal value',
                              an_instance_of(klass),
                              an_instance_of(klass))
      end

      it 'updates values with enriched versions' do
        creators = enriched.sourceResource.first.creator.select do |o|
          o.is_a?(klass)
        end
        creators.each { |val| expect(val.providedLabel).to eq [updated_value] }
      end

      context 'when node is missing property' do
        before do
          record.sourceResource.first.creator << node
        end

        let(:node) do
          creator = ActiveTriples::Resource.new
          creator.set_value(RDF::DC.title, 'moomin')
          creator
        end

        it 'leaves node unaltered' do
          expect(record.sourceResource.first.creator).to include node
        end
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

    context 'with field arguments' do
      let(:simple_field) { :preview }
      let(:deep_field) do
        { :sourceResource => { :creator => :providedLabel } }
      end
      let(:deep_field_2) do
        { :sourceResource => { :spatial => :parentFeature } }
      end

      let(:deep_field_chain)   { [:sourceResource, :creator, :providedLabel] }
      let(:deep_field_2_chain)   { [:sourceResource, :spatial, :parentFeature] }

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
        expect(subject).to receive(:enrich_field)
          .with(record, deep_field_2_chain)
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
