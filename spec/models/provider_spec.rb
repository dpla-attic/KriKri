require 'spec_helper'

describe Krikri::Provider do
  it_behaves_like 'ActiveModel'

  let(:provider_base) { Krikri::Settings.prov.provider_base }
  let(:id) { '123' }
  let(:rdf_subject) { provider_base + id }
  let(:name) { 'Snork Maiden Archives' }

  let(:agg) do
    p = DPLA::MAP::Agent.new(RDF::URI(provider_base) / id)
    p.label = name
    build(:aggregation, :provider => p)
  end

  let(:bnode) do
    p = DPLA::MAP::Agent.new
    build(:aggregation, :provider => p)
  end

  shared_context 'indexed in Solr' do
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

  shared_context 'bnode indexed in Solr' do
    before do
      indexer = Krikri::QASearchIndex.new
      indexer.add bnode.to_jsonld['@graph'].first
      indexer.commit
    end

    after do
      indexer = Krikri::QASearchIndex.new
      indexer.delete_by_query(['*:*'])
      indexer.commit
    end
  end

  describe '#initialize' do

    it 'sets given attributes' do
      expect(described_class.new({ rdf_subject: rdf_subject }).rdf_subject)
        .to eq rdf_subject
    end
  end

  describe '#all' do
    it 'with no items is empty' do
      expect(described_class.all).to be_empty
    end

    context 'with valid item' do
      include_context 'indexed in Solr'

      it 'returns valid item' do
        expect(described_class.all.map(&:rdf_subject))
          .to contain_exactly rdf_subject
      end

      it 'assigns :name Providers' do
        expect(described_class.all.map(&:name))
          .to include name
      end
    end

    context 'with bnode' do
      include_context 'bnode indexed in Solr'

      it 'ingnores bnode' do
        expect(described_class.all).to be_empty
      end
    end
  end

  describe '#find' do

    it 'returns nil if item not found' do
      expect(described_class.find(id)).to eq nil
    end

    context 'with item' do
      include_context 'indexed in Solr'

      it 'finds the provider with a given :id' do
        expect(described_class.find(id).name).to eq name
      end

      it 'finds the provider with a given :rdf_subject' do
        expect(described_class.find(rdf_subject).name).to eq name
      end
    end
  end

  describe '#base_uri' do

    it 'adds trailing "/" to provider_base if missing' do
      allow(Krikri::Settings).to receive_message_chain('prov.provider_base')
        .and_return 'http://example.com/abc'
      expect(described_class.base_uri).to eq('http://example.com/abc/')
    end
  end

  describe '#id' do

    it 'returns an :id parsed from :rdf_subject' do
      expect(described_class.new({ rdf_subject: rdf_subject }).id).to eq id
    end

    it 'returns nil without valid :rdf_subject' do
      expect(described_class.new.id).to eq nil
    end
  end

  describe '#name' do

    context 'with item' do
      include_context 'indexed in Solr'

      it 'returns an :name corresponding to the indexed :rdf_subject' do
        expect(described_class.new({ rdf_subject: rdf_subject }).name)
          .to eq name
      end

      it 'returns nil without valid :rdf_subject' do
        expect(described_class.new.name).to eq nil
      end
    end

    it 'returns :rdf_subject without indexed :provider_name' do
      allow_any_instance_of(Blacklight::SolrResponse).to receive(:docs)
        .and_return([{ 'provider_id' => [rdf_subject] }])
      expect(described_class.new({ rdf_subject: rdf_subject }).name)
        .to eq rdf_subject
    end
  end

  describe '#agent' do
    include_context 'indexed in Solr'

    it 'returns a DPLA::MAP::Agent object' do
      expect(described_class.find(rdf_subject).agent)
        .to be_a DPLA::MAP::Agent
    end

    it 'assigns :rdf_subject to agent' do
      agent = (described_class.find(rdf_subject).agent)
      expect(agent.rdf_subject.to_s).to eq rdf_subject
    end

    it 'assigns :name to agent' do
      agent = (described_class.find(rdf_subject).agent)
      expect(agent.label.first).to eq name
    end

    it 'returns nil without valid :rdf_subject' do
      expect(described_class.new.agent).to eq nil
    end
  end

  describe '#field_value_reports' do

    before(:each) do
      allow(Krikri::FieldValueReport).to receive(:fields).and_return(['abc'])
    end

    it 'returns an Array' do
      expect(described_class.new.field_value_reports).to be_a Array
    end

    it 'returns FieldValueReports' do
      expect(described_class.new.field_value_reports.first)
        .to be_a Krikri::FieldValueReport
    end

    it 'assigns provider to FieldValueReports' do
      provider = described_class.new({ rdf_subject: rdf_subject })
      expect(provider.field_value_reports.first.provider).to eq provider
    end

    it 'assigns field name to FieldValueReports' do
      expect(described_class.new.field_value_reports.first.field).to eq 'abc'
    end
  end

  describe '#valid_rdf_subject?' do
    it 'recognizes bnodes' do
      provider = Krikri::Provider.new({ rdf_subject: '_:b1' })
      expect(provider.valid_rdf_subject?).to eq false
    end
  end
end
