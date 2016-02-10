require 'spec_helper'

describe Krikri::MappingDSL::RdfSubjects do
  before do
    # dummy class
    class DummyParserImpl
      include Krikri::MappingDSL::RdfSubjects

      def properties
        @properties ||= []
      end
    end
  end

  after do
    Object.send(:remove_const, 'DummyParserImpl')
  end

  subject { DummyParserImpl.new }
  let(:value) { 'http://example.org/items/1' }

  describe '#uri' do
    before do
      expect(Krikri::MappingDSL::RdfSubjects::SubjectDeclaration).to receive(:new)
        .with(nil, value).and_return(declaration)
      subject.uri value
    end

    let(:declaration) do
      instance_double(Krikri::MappingDSL::RdfSubjects::SubjectDeclaration)
    end

    it 'adds a subject declaration' do
      expect(subject.properties).to include(declaration)
    end

    context 'with overwritten property' do
      before do
        expect(Krikri::MappingDSL::RdfSubjects::SubjectDeclaration).to receive(:new)
          .with(nil, value).and_return(new_declaration)

        allow(declaration).to receive(:is_a?)
          .with(Krikri::MappingDSL::RdfSubjects::SubjectDeclaration)
          .and_return(true)

        subject.uri value
      end

      let(:new_declaration) do
        instance_double(Krikri::MappingDSL::RdfSubjects::SubjectDeclaration)
      end

      it 'adds new property' do
        expect(subject.properties).to include(new_declaration)
      end

      it 'deletes old property' do
        expect(subject.properties).not_to include(declaration)
      end
    end
  end

  describe Krikri::MappingDSL::RdfSubjects::SubjectDeclaration do
    subject { described_class.new(nil, value) }

    it 'has value' do
      expect(subject.value).to eq value
    end

    describe '#to_proc' do
      let(:mapped) { double }

      shared_examples 'uri setting' do
        it 'sets subject' do
          expect(mapped).to receive(:set_subject!).with(value)
          subject.to_proc.call(mapped, '')
        end

        context 'with block' do
          subject do
            described_class.new(nil, value) do |v|
              v.upcase
            end
          end

          it 'passes value through block' do
            expect(mapped).to receive(:set_subject!).with(value.upcase)
            subject.to_proc.call(mapped, '')
          end
        end
      end

      context 'with single value' do
        include_examples 'uri setting'
      end

      context 'with value array of count 1' do
        include_examples 'uri setting'
        subject { described_class.new(nil, array_value) }
        let(:array_value) { [value] }
      end

      context 'with no values' do
        let(:value) { [] }
        let(:node) { RDF::Node.new }

        before { allow(mapped).to receive(:rdf_subject).and_return(node) }

        it 'gives the bnode subject' do
          expect(subject.to_proc.call(mapped, '')).to eq node
        end

        it 'leaves the rdf_subject untouched' do
          expect(mapped).not_to receive(:set_subject!)
          subject.to_proc.call(mapped, '')
        end
      end

      context 'with too many values' do
        let(:value) { ['http://example.org/1', 'http://example.org/2'] }

        it 'raises an error' do
          expect { subject.to_proc.call(mapped, '') }
            .to raise_error start_with('Error mapping')
        end
      end
    end
  end
end
