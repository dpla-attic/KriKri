require 'spec_helper'

describe Krikri::Mapping do

  let(:target_class) { double('target class') }
  let(:parser) { double('parser') }
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

    shared_context 'property declarations' do
      before do
        allow(target_class).to receive(:new).and_return(target_instance)
        allow(target_instance).to receive(:my_property=).and_return('')
        allow(parser).to receive(:parse).and_return(record)
        subject.my_property ''
      end

      subject { described_class.new(target_class, parser, *parser_args) }
      let(:target_instance) { double('target instance') }
    end
    
    describe 'error handling' do  
      include_context 'property declarations'

      before do
        allow(target_instance).to receive(:error_property=).and_raise error
        subject.error_property 'moomin'
      end

      let(:error) { RuntimeError.new }
    
      it 'catches errors and raises Mapping::Error ' do
        expect { subject.process_record(record) }
          .to raise_error described_class::Error
      end

      it 'tracks failed properties' do
        begin 
          subject.process_record(record)
        rescue described_class::Error => err
          expect(err.properties).to contain_exactly :error_property
        end
      end

      it 'stores properties and errors in Mapping::Error' do
        begin 
          subject.process_record(record)
        rescue described_class::Error => err
          expect(err.errors[:error_property]).to eq error
        end
      end
    end

    context 'with parser' do
      include_context 'property declarations'

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
