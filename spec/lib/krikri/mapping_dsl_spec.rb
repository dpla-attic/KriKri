require 'spec_helper'

describe Krikri::MappingDSL do
  before do
    # dummy class
    class DummyMappingImplementation
      include Krikri::MappingDSL
    end
  end

  after do
    Object.send(:remove_const, 'DummyMappingImplementation')
  end

  let(:mapping) { DummyMappingImplementation.new }
  let(:value) { 'value' }

  it 'knows it responds to missing methods' do
    expect(mapping.respond_to?(:blah)).to be true
  end

  describe '#add_property' do
    describe 'static' do
      before do
        expect(Krikri::MappingDSL::PropertyDeclaration).to receive(:new)
          .with(:my_property, value).and_return(declaration)
        mapping.my_property value
      end

      let(:declaration) do
        instance_double(Krikri::MappingDSL::PropertyDeclaration,
                        :name => :my_property, :value => value)
      end

      it 'adds properties' do
        expect(mapping.properties).to include(declaration)
      end

      context 'with overwritten property' do
        before do
          expect(Krikri::MappingDSL::PropertyDeclaration).to receive(:new)
            .with(:my_property, 'new_value').and_return(new_declaration)
          mapping.my_property 'new_value'
        end

        let(:new_declaration) do
          instance_double(Krikri::MappingDSL::PropertyDeclaration,
                          :name => :my_property, :value => 'new_value')
        end

        it 'adds new property' do
          expect(mapping.properties).to include(new_declaration)
        end

        it 'deletes old property' do
          expect(mapping.properties).not_to include(declaration)
        end
      end
    end
  end

  describe '#add_child' do
    before do
      mapping.aggregatedCHO :class => DPLA::MAP::SourceResource do
        title 'Comet in Moominland'

        creator :class => DPLA::MAP::Agent do
          label 'Tove Jansson'
        end
      end
    end

    it 'builds resource params as property value' do
      mapped = DPLA::MAP::Aggregation.new
      mapping.properties.first.to_proc.call(mapped, '')
      expect(mapped.aggregatedCHO.first.creator.first.label)
        .to contain_exactly('Tove Jansson')
    end
  end

  shared_examples 'a named property' do
    it 'has name' do
      expect(subject.name).to eq :my_property
    end
  end

  shared_examples 'a valued property' do
    it 'has value' do
      expect(subject.value).to eq value
    end
  end

  describe Krikri::MappingDSL::PropertyDeclaration do
    it_behaves_like 'a named property'
    it_behaves_like 'a valued property'

    subject { described_class.new(:my_property, value) }

    describe '#to_proc' do
      shared_context 'mapped property' do
        before do
          expect(mapped).to receive(:my_property=).with(value)
        end
        let(:mapped) { double }
      end

      shared_context 'property block' do
        subject do
          described_class.new(:my_property, start_value) do |v|
            v.upcase
          end
        end
        let(:start_value) do
          return value.map(&:downcase) if value.is_a? Enumerable
          value.downcase
        end
      end

      shared_examples 'a property value' do
        it 'gives a proc that sets value' do
          subject.to_proc.call(mapped, '')
        end
      end

      context 'static' do
        include_context 'mapped property'
        it_behaves_like 'a property value'
      end

      context 'with multiple values' do
        include_context 'mapped property'
        it_behaves_like 'a property value'

        let(:value) { %w('value_1', 'value_2') }

        context 'with block of arity 1' do
          include_context 'property block'
          it_behaves_like 'a property value'

          let(:value) { %w('value_1', 'value_2').map(&:upcase) }
        end
      end

      context 'with block of arity 1' do
        include_context 'mapped property'
        include_context 'property block'
        it_behaves_like 'a property value'

        let(:value) { 'value'.upcase }
      end

      context 'with callable value' do
        include_context 'mapped property'
        it_behaves_like 'a property value'

        before do
          expect(proc_value).to receive(:call).and_return(value)
        end

        subject { described_class.new(:my_property, proc_value) }

        let(:proc_value) { ->(_) {} }
      end

      context 'with block of wrong arity' do
        subject do
          described_class.new(:my_property, value) { |v, what| v + what }
        end

        it 'raises error' do
          expect { subject.to_proc.call(nil, nil) }
            .to raise_error('Block must have arity of 1 to be applied to '\
                            'property')
        end
      end
    end
  end

  describe Krikri::MappingDSL::ChildDeclaration do
    it_behaves_like 'a named property'
    subject { described_class.new(:my_property, klass) {} }
    let(:klass) { double }

    describe '#to_proc' do
      let(:mapping) { double }
      let(:target) { double }

      before do
        allow(::Krikri::Mapping).to receive(:new).and_return(mapping)
        allow(mapping).to receive(:process_record).with('').and_return(:value)
      end

      it 'returns a proc' do
        expect(target).to receive(:my_property=).with(:value)
        subject.to_proc.call(target, '')
      end
    end
  end
end
