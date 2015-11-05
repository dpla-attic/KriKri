require 'spec_helper'

describe Krikri::Parser::ValueArray do
  subject { described_class.new(values) }
  let(:values) do
    vs = []
    3.times do |n|
      vs << double('value', :value => "value_#{n}")
    end
    vs
  end

  it 'is an Array' do
    expect(subject.to_a).to be_a Array
  end

  describe '.build' do
    let(:record) { instance_double(Krikri::Parser, :root => :root_node) }

    it 'builds with root node' do
      expect(described_class.build(record)).to contain_exactly(:root_node)
    end
  end

  describe '#values' do
    before do
      values.each do |v|
        allow(v).to receive(:respond_to?).with(:value).and_return(true)
      end
    end

    it 'gives values for items in array' do
      expect(subject.values).to eq ['value_0', 'value_1', 'value_2']
    end

    it 'gives item when item has no value property' do
      values << double('valueless')
      expect(subject.values).to eq ['value_0', 'value_1', 'value_2', values.last]
    end
  end

  shared_context 'with fields' do
    before do
      values.each do |val|
        nested_field = instance_double(Krikri::Parser::Value)
        allow(val).to receive(:[]).with(:field_name)
                       .and_return(nested_field)
        allow(val).to receive(:[]).with(:nonexistent_field)
                       .and_return(described_class.new([]))
        allow(nested_field).to receive(:[]).with(:nested_name)
                                .and_return(:final_value)
        allow(nested_field).to receive(:[]).with(:nonexistent_field)
                       .and_return(described_class.new([]))
      end
    end
  end

  describe '#[]=' do
    it 'raises error when invalid values are added' do
      expect { subject[0] = 1 }
        .to raise_error described_class::InvalidParserValueError
    end

    it 'adds item to array' do
      value = Krikri::Parser::Value.new
      subject[0] = value
      expect(subject).to include value
    end
  end

  describe '#<<' do
    it 'raises error when invalid values are added' do
      expect { subject << 1 }
        .to raise_error described_class::InvalidParserValueError
    end

    it 'adds to count' do
      value = Krikri::Parser::Value.new
      expect { subject << value }.to change { subject.count }.by(1)
    end

    it 'adds item to array' do
      value = Krikri::Parser::Value.new
      subject << value
      expect(subject).to include value
    end
  end


  describe '#if' do
    include_context 'with fields'

    it 'returns self with top set' do
      expect(subject.if).to eq subject
    end

    context 'with block given' do
      it 'yields a copy of itself' do
        expect { |b| subject.if(&b) }
          .to yield_with_args(a_collection_containing_exactly(*subject))
      end

      it 'returns result if non-empty' do
        expect(subject.if { |rec| rec.field(:field_name, :nested_name) })
          .to contain_exactly(:final_value, :final_value, :final_value)
      end
    end
  end

  describe '#else' do
    include_context 'with fields'

    it 'raises an argument error if no block is given ' do
      expect { subject.else }.to raise_error ArgumentError
    end

    it 'evaluates block on root for empty result ' do
      expect(
        subject.field(:nonexistent_field).else do |rec|
          rec.field(:field_name, :nested_name)
        end
      ).to contain_exactly(:final_value, :final_value, :final_value)
    end

    it 'skips block on root for non-empty result ' do
      expect { |b| subject.field(:field_name).else(&b) }
        .not_to yield_control
    end

    context 'with #if' do
      it 'recovers from @top set by #if' do
        expect(
          subject.field(:field_name).if.field(:nonexistent_field).else do |rec|
            rec.field(:nested_name)
          end
        ).to contain_exactly(:final_value, :final_value, :final_value)
      end

      it 'skips block on root for non-empty result ' do
        expect do |b|
          subject.field(:field_name).if.field(:nested_name).else(&b)
        end.not_to yield_control
      end
    end
  end

  describe '#field' do
    include_context 'with fields'

    it 'gives values from a field' do
      expect(subject.field(:field_name, :nested_name))
        .to contain_exactly(:final_value, :final_value, :final_value)
    end

    it 'returns nil for a nonexistent field' do
      expect(subject.field(:nonexistent_field)).to be_empty
    end

    it 'returns an instance of its class' do
      expect(subject.field(:field_name)).to be_a described_class
    end
  end

  describe '#fields' do
    include_context 'with fields'

    it 'returns single field' do
      expect(subject.fields(:field_name))
        .to contain_exactly(*subject.field(:field_name))
    end

    it 'returns single field when passed as array' do
      expect(subject.fields([:field_name]))
        .to contain_exactly(*subject.field(:field_name))
    end

    it 'returns nested fields when passed as array' do
      expect(subject.fields([:field_name, :nested_name]))
        .to contain_exactly(*subject.field(:field_name, :nested_name))
    end

    it 'returns union of fields when some are nested' do
      expect(subject.fields([:field_name, :nested_name], :field_name))
        .to contain_exactly(*subject.field(:field_name)
                             .concat(subject.field(:field_name, :nested_name)))
    end

    it 'returns union of fields when all are nested' do
      expect(subject.fields([:field_name, :nested_name], [:field_name]))
        .to contain_exactly(*subject.field(:field_name)
                              .concat(subject.field(:field_name, :nested_name)))
    end

    it 'returns union of fields when some are nonexistent' do
      expect(subject.fields([:field_name, :nested_name], [:nonexistent_field]))
        .to contain_exactly(*subject.field(:field_name, :nested_name))
    end
  end

  describe '#first_value' do
    it 'returns a single item ValueArray without an arguments' do
      expect(subject.first_value).to contain_exactly values[0]
    end

    it 'returns only requested items when called with an argument' do
      expect(subject.first_value(2)).to contain_exactly(values[0], values[1])
      expect(subject.first_value(2).count).to eq(2)
    end

    it 'returns an instance of its class' do
      expect(subject.first_value).to be_a described_class
    end

    context 'with empty field' do
      let(:values) { [] }

      it 'returns an empty ValueArray' do
        expect(subject.first_value).to be_empty
      end
    end
  end

  describe '#last_value' do
    it 'returns a single item ValueArray without an argument' do
      expect(subject.last_value).to contain_exactly values.last
    end

    it 'returns only requested items when called with an argument' do
      expect(subject.last_value(2)).to contain_exactly(*values[-2..-1])
      expect(subject.last_value(2).count).to eq(2)
    end

    it 'returns an instance of its class' do
      expect(subject.last_value).to be_a described_class
    end

    context 'with empty field' do
      let(:values) { [] }

      it 'returns an empty ValueArray' do
        expect(subject.last_value).to be_empty
      end
    end
  end

  describe '#concat' do
    it 'gives union of two arrays' do
      vals = subject.to_a.dup
      expect(subject.concat(vals)).to contain_exactly(*vals.concat(vals))
    end

    it 'returns an instance of its class' do
      expect(subject.concat(subject)).to be_a described_class
    end
  end

  describe '#flatten' do
    it do
      vals = subject.to_a.dup
      new_val_arry = described_class.new(subject)
      expect(new_val_arry.flatten).to contain_exactly(*vals)
    end

    it 'returns an instance of its class' do
      expect(subject.flatten).to be_a described_class
    end
  end

  describe '#select' do
    it 'creates new array with selected values' do
      expect(subject.select { |v| v.value == 'value_1'})
        .to contain_exactly(values[1])
    end

    it 'returns an instance of its class' do
      expect(subject.select {}).to be_a described_class
    end
  end

  describe '#map' do
    it 'calls block on all' do
      expect { |b| subject.map(&b) }.to yield_successive_args(*subject.to_a)
    end

    it 'returns an instance of its class' do
      expect(subject.map {}).to be_a described_class
    end
  end

  describe '#reject' do
    it 'creates new array not containing rejected values' do
      expect(subject.reject { |v| v.value == 'value_1'})
        .not_to include values[1]
    end

    it 'returns an instance of its class' do
      expect(subject.reject {}).to be_a described_class
    end
  end

  shared_context 'with attributes' do
    before do
      values.each { |val| allow(val).to receive(:attribute?).and_return(false) }

      allow(values[0]).to receive(:attribute?).with(:type).and_return(true)
      allow(values[0]).to receive(:type).and_return('Moomin')
      allow(values[1]).to receive(:attribute?).with(:type).and_return(true)
      allow(values[1]).to receive(:type).and_return('mummi')
    end
  end

  describe '#match_attribute' do
    include_context 'with attributes'

    it 'selects values by presence of attributes' do
      expect(subject.match_attribute(:type))
        .to contain_exactly(values[0], values[1])
    end

    it 'selects values by attribute values matching other' do
      expect(subject.match_attribute(:type, 'Moomin'))
        .to contain_exactly(values[0])
    end

    it 'selects according to a given block' do
      expect(subject.match_attribute(:type) { |v| v.starts_with?('mu') })
        .to contain_exactly(values[1])
    end

    it 'selects according to a given block and comparison to other' do
      expect(subject.match_attribute(:type, 'moomin') { |v| v.downcase })
        .to contain_exactly(values[0])
    end
  end

  describe '#reject_attribute' do
    include_context 'with attributes'

    it 'rejects values by presence of attributes' do
      expect(subject.reject_attribute(:type)).to contain_exactly(values[2])
    end

    it 'selects values by attribute values matching other' do
      expect(subject.reject_attribute(:type, 'Moomin'))
        .to contain_exactly(values[1], values[2])
    end

    it 'selects according to a given block' do
      expect(subject.reject_attribute(:type) { |v| v.starts_with?('mu') })
        .to contain_exactly(values[0], values[2])
    end

    it 'selects according to a given block and comparison to other' do
      expect(subject.reject_attribute(:type, 'moomin') { |v| v.downcase })
        .to contain_exactly(values[1], values[2])
    end
  end
end
