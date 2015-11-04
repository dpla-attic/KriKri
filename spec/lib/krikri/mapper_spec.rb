require 'spec_helper'

describe Krikri::Mapper do
  describe 'integration' do
    before do
      Krikri::Mapper.define(:integration) do
        sourceResource :class => DPLA::MAP::SourceResource do
          title record.field('dc:title')
          # test non-root methods
          identifier header.field('xmlns:identifier')

          creator :class => DPLA::MAP::Agent do
            providedLabel record.field('dc:creator')
          end

          contributor :class => DPLA::MAP::Agent, :each => record.field('dc:creator').map { |v| v.value }, :as => :ident do
            providedLabel ident
          end

          spatial :class => DPLA::MAP::Place, :each => ['nyc', 'bos', 'pdx'], :as => :place do
            providedLabel place
          end
        end

        provider :class => DPLA::MAP::Agent, :each => header.field('xmlns:identifier'), :as => :ident do
          providedLabel ident
        end
      end
    end

    let(:record) { Krikri::OaiDcParser.new(build(:oai_dc_record)) }

    it 'maps nested values' do
      mapped = Krikri::Mapper.map(:integration, record).first

      expect(mapped.sourceResource.first.creator.first.providedLabel)
        .to eq record.root['dc:creator'].to_a.map(&:value)

      expect(mapped.sourceResource.first.contributor.first.providedLabel)
        .to contain_exactly record.root['dc:creator'].first.value
      expect(mapped.sourceResource.first.contributor.map(&:providedLabel).flatten)
        .to eq record.root['dc:creator'].to_a.map(&:value)

      expect(mapped.sourceResource.first.spatial.map(&:providedLabel).flatten)
        .to eq ['nyc', 'bos', 'pdx']

      expect(mapped.sourceResource.first.identifier)
        .to eq Array(record.header.first['xmlns:identifier'].first.value)
      expect(mapped.provider.first.providedLabel)
        .to eq Array(record.header.first['xmlns:identifier'].first.value)
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
      expect(Krikri::Mapping).to receive(:new)
        .with(klass, Krikri::XmlParser).once
      Krikri::Mapper.define(:klass_map, class: klass)
    end

    it 'passes parser to mapping' do
      parser = Class.new
      expect(Krikri::Mapping).to receive(:new)
        .with(DPLA::MAP::Aggregation, parser).once
      Krikri::Mapper.define(:klass_map, parser: parser)
    end

    it 'passes parser_args to mapping' do
      args = [1,2,3]
      expect(Krikri::Mapping).to receive(:new)
        .with(DPLA::MAP::Aggregation, Krikri::XmlParser, *args).once
      Krikri::Mapper.define(:klass_map, parser_args: args)
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
      let(:records) do
        [record.clone, record.clone, record.clone]
      end

      context 'with no errors' do
        before do
          records.each do |rec|
            expect(mapping).to receive(:process_record).with(rec)
                                .and_return(:mapped_record).ordered
          end
        end

        it 'returns a list of items returned by mapping' do
          expect(Krikri::Mapper.map(:my_map_2, records))
            .to contain_exactly(:mapped_record, :mapped_record, :mapped_record)
        end
      end

      context 'with errors thrown' do
        before do
          allow(record).to receive(:rdf_subject).and_return('123')

          records.each do |rec|
            allow(mapping).to receive(:process_record).with(rec)
                               .and_raise(StandardError.new)
          end
        end

        it 'logs errors and continues' do
          expect(Rails.logger).to receive(:error).exactly(3).times
          Krikri::Mapper.map(:my_map_2, records)
        end

        it 'logs errors and continues' do
          expect(Krikri::Mapper.map(:my_map_2, records)).to eq [nil, nil, nil]
        end
      end
    end
  end
end
