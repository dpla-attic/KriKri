require 'spec_helper'

describe Krikri::MappingDSL::ParserMethods do
  before do
    # dummy class
    class DummyParserImpl
      include Krikri::MappingDSL::ParserMethods
    end
  end

  after do
    Object.send(:remove_const, 'DummyParserImpl')
  end

  subject { DummyParserImpl.new }

  let(:record) { instance_double('Krikri::XmlParser') }
  let(:real) { Krikri::XmlParser.new(build(:oai_dc_record)) }

  describe '#record' do
    it 'returns a callable proc' do
      expect(subject.record).to be_a Proc
    end

    it 'has arity of 1 (for parsed record)' do
      expect(subject.record.arity).to eq 1
    end

    context 'when passed record' do
      before do
        allow(record).to receive(:root).and_return(:value)
      end

      it 'record to given block' do
        expect { |blk| subject.record(&blk).call(record) }
          .to yield_with_args(:value)
      end
    end
  end
end
