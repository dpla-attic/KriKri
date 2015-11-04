require 'spec_helper'

describe Krikri::Harvesters::MarcXMLHarvester do
  subject { canned_harvester.new(sample_records, args) }

  let(:canned_harvester) do
    Class.new(described_class) do
      def initialize(canned_records, *opts)
        @canned_records = canned_records
        super(*opts)
      end

      def each_collection
        collection = ['<collection>',
                      *@canned_records,
                      '</collection>'].join('')
        yield(StringIO.new(collection))
      end
    end
  end

  let(:sample_records) do
    [
      '<record xmlns="http://www.loc.gov/MARC21/slim">
        <leader>01015nam a22003011  4500</leader>
        <controlfield tag="001">001</controlfield>
        <datafield tag="245" ind1="1" ind2="4">
          <subfield code="a">An incomplete sample record</subfield>
        </datafield>
       </record>',
      '<record xmlns="http://www.loc.gov/MARC21/slim">
        <leader>01015nam a22003011  4500</leader>
        <controlfield tag="001">002</controlfield>
        <datafield tag="245" ind1="1" ind2="4">
          <subfield code="a">A second incomplete sample record</subfield>
        </datafield>
       </record>',
      '<record xmlns="http://www.loc.gov/MARC21/slim">
        <leader>01015nam a22003011  4500</leader>
        <controlfield tag="001">003</controlfield>
        <datafield tag="245" ind1="1" ind2="4">
          <subfield code="a">A third incomplete sample record</subfield>
        </datafield>
       </record>'
    ]
  end

  let(:args) { { uri: 'http://example.org/endpoint' } }

  describe '#content_type' do
    it 'is "text/xml"' do
      expect(subject.content_type).to eq 'text/xml'
    end
  end

  context 'record parsing' do
    describe '#records' do
      it 'can enumerate sample records' do
        marcxml_records = subject.records.map(&:content)

        expect(sample_records).to match_array(marcxml_records)
      end
    end

    describe '#record_ids' do
      it 'can extract identifiers from the 001 control field' do
        expect(subject.record_ids).to match_array(%w(001 002 003))
      end
    end
  end
end
