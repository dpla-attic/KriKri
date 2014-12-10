require 'spec_helper'

describe Krikri::MappingDSL::PropertyDeclaration do
  include_context 'mapping dsl'
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
