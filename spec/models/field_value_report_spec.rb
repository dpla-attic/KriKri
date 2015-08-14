require 'spec_helper'

describe Krikri::FieldValueReport do
  it_behaves_like 'ActiveModel'

  let(:field) { 'sourceResource_title' }
  let(:provider_base) { Krikri::Settings.prov.provider_base }
  let(:provider_id) { '123' }
  let(:report) { described_class.find(field, provider_id) }

  let(:agg) do
    p = DPLA::MAP::Agent.new(RDF::URI(provider_base) / provider_id)
    build(:aggregation, :provider => p)
  end

  shared_context 'item indexed in Solr' do
    before do
      clear_search_index
      indexer = Krikri::QASearchIndex.new
      indexer.add agg.to_jsonld['@graph'].first
      indexer.commit
    end

    after do
      clear_search_index
    end
  end

  describe '#find' do
    include_context 'item indexed in Solr'

    it 'returns nil if field is invalid' do
      expect(described_class.find('invalid', provider_id)).to eq nil
    end

    it 'returns nil if provider not found' do
      expect(described_class.find(field, 'invalid')).to eq nil
    end

    it 'returns a FieldValueReport object' do
      expect(report).to be_a Krikri::FieldValueReport
    end

    it 'assigns instance variables' do
      expect(report.field).to eq field
    end
  end

  describe '#fields' do
    it 'returns an Array' do
      expect(described_class.fields).to be_a Array
    end
  end

  describe '#enumerate_rows' do
    include_context 'item indexed in Solr'

    it 'returns an enumerator' do
      expect(report.enumerate_rows).to be_a Enumerator
    end

    it 'contains arrays' do
      expect(report.enumerate_rows.first).to be_a Array
    end

    it 'returns correct values' do
      expect(report.enumerate_rows.first).to include('Stonewall Inn [2]')
    end

    it 'returns "__MISSING__" for field without value' do
      r = described_class.find('sourceResource_alternative_providedLabel',
                               provider_id)
      expect(r.enumerate_rows.first).to include('__MISSING__')
    end

    context 'with opts' do
      it 'sets :rows' do
        opts = { rows: 50 }
        expect(report.instance_eval{ query_opts(opts) }).to include opts
      end
    end
  end
end
