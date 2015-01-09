require 'spec_helper'

describe Krikri::Mapper do
  describe 'integration' do
    before do
      Krikri::Mapper.define(:integration) do
        sourceResource :class => DPLA::MAP::SourceResource do
          title record { |rec| rec['dc:title'].map(&:value) }

          creator :class => DPLA::MAP::Agent do
            providedLabel record { |rec| rec['dc:creator'].map(&:value) }
          end
        end
      end
    end

    let(:record) { Krikri::OaiDcParser.new(build(:oai_dc_record)) }

    it 'maps nested values' do
      mapped = Krikri::Mapper.map(:integration, record).first
      expect(mapped.sourceResource.first.creator.first.providedLabel)
        .to eq record.root['dc:creator'].map(&:value)
    end
  end

  describe '#define' do
    it 'registers a mapping' do
      Krikri::Mapper.define :metadata_map
      expect(Krikri::Mapper::Registry.registered?(:metadata_map)).to be true
    end

    it 'returns a mapping' do
      expect(Krikri::Mapper.define(:another_map)).to be_a Krikri::Mapping
    end

    it 'passes target class to mapping' do
      klass = Class.new
      expect(Krikri::Mapping).to receive(:new).with(klass).once
      Krikri::Mapper.define(:klass_map, class: klass)
    end

    it 'hits DSL methods' do
      expect_any_instance_of(Krikri::Mapping).to receive(:dsl_method_1)
        .with(:arg1, :arg2)
      expect_any_instance_of(Krikri::Mapping).to receive(:dsl_method_2)
        .with(:arg1)

      Krikri::Mapper.define :my_map do
        dsl_method_1 :arg1, :arg2
        dsl_method_2 :arg1
      end
    end
  end

  describe '#map' do
    before(:all) do
      Krikri::Mapper.define :my_map_2 do
        provider 'NYPL'
      end
    end

    let(:record) { instance_double(Krikri::OriginalRecord) }
    let(:mapping) { Krikri::Mapper::Registry.get(:my_map_2) }

    context 'with single record' do
      before do
        expect(mapping).to receive(:process_record).with(record)
          .and_return(:mapped_record)
      end

      it 'returns a list of items returned by mapping' do
        expect(Krikri::Mapper.map(:my_map_2, record))
          .to contain_exactly(:mapped_record)
      end
    end

    context 'with multiple records' do
      before do
        records.each do |rec|
          expect(mapping).to receive(:process_record).with(rec)
            .and_return(:mapped_record).ordered
        end
      end

      let(:records) do
        [record.clone, record.clone, record.clone]
      end

      it 'returns a list of items returned by mapping' do
        expect(Krikri::Mapper.map(:my_map_2, records))
          .to contain_exactly(:mapped_record, :mapped_record, :mapped_record)
      end
    end
  end

end
