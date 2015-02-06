require 'spec_helper'

describe Krikri::Mapping do

  let(:target_class) { double }
  let(:parser) { double }
  let(:parser_args) { [1,2,3] }

  describe '#new' do
    it 'accepts target class, parser, and parser arguments' do
      expect(described_class.new(target_class, parser, *parser_args))
        .to have_attributes(klass: target_class,
                            parser: parser,
                            parser_args: parser_args)
    end
  end

  describe '#process_record' do
    let(:record) { build(:oai_dc_record) }

    it 'creates a DPLA::MAP record' do
      expect(subject.process_record(record)).to be_a DPLA::MAP::Aggregation
    end

    it 'builds target class set in initializer' do
      klass = DPLA::MAP::SourceResource
      new_mapping = Krikri::Mapping.new(klass)
      expect(new_mapping.process_record(record)).to be_a klass
    end

    context 'with parser' do
      before do
        target_instance = double
        allow(target_class).to receive(:new).and_return(target_instance)
        allow(target_instance).to receive(:my_property=).and_return('')
        subject.my_property ''
      end

      subject { described_class.new(target_class, parser, *parser_args) }

      it 'parses record before mapping' do
        expect(parser)
          .to receive(:parse).with(record, *parser_args).and_return(record)
        subject.process_record(record)
      end
    end

    context 'with static properties' do
      before do
        subject.rightsStatement value
      end

      subject { described_class.new }
      let(:value) { 'Rights Reserved; Moomin Access Only' }

      it 'sets value' do
        expect_any_instance_of(DPLA::MAP::Aggregation)
          .to receive(:rightsStatement=).with(value)
        subject.process_record(record)
      end
    end
  end
end
