shared_examples_for 'a parser' do
  let(:parser) { subject || described_class.new(record) }

  it 'has a root node' do
    expect(parser.root).to be_a Krikri::Parser::Value
  end

  it 'has a record' do
    expect(parser.record).to eql record
  end
end

shared_examples_for 'a parser value' do
  let(:value) { subject || described_class.new }
  let(:child) { value.children.first }
  let(:attr) { value.attributes.first }

  describe '#children' do
    it 'has children' do
      expect(value.children).to all(be_a(String))
    end
  end

  describe '#[]' do
    it 'retrieves a child node' do
      expect(value[child]).to include(an_instance_of(described_class))
    end
  end

  describe '#child?' do
    it 'knows its children' do
      expect(value.child?(child)).to be true
    end

    it 'knows its non-children' do
      expect(value.child?(:fake)).to be false
    end
  end

  describe '#value' do
    it 'gives a datatype representation' do
      expect(value[child].first.value).to respond_to :to_s
    end
  end

  describe '#values?' do
    it 'has typed values' do
      expect(value[child].first.values?).to be true
    end
  end
end

shared_examples_for 'a parser value that has attributes' do
  let(:value) { subject || described_class.new }
  let(:child) { value.children.first }
  let(:attr) { value.attributes.first }

  describe '#attributes' do
    it 'has an attribute list as symbols' do
      expect(value.attributes).to all(be_a(Symbol))
    end
  end

  describe '#attribute?' do
    it 'knows its attributes' do
      expect(value.attribute?(attr)).to be true
    end

    it 'knows its non-attributes' do
      expect(value.attribute?(:fake)).to be false
    end
  end

  describe 'attribute accessors' do
    it 'responds to attributes with #method_missing' do
      expect(value.send(attr)).to respond_to :to_s
    end

    it 'raises not found if attribute does not exist' do
      expect { value.send(:fake) }.to raise_error NoMethodError
    end
  end
end
