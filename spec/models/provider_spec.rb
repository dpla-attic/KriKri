require 'spec_helper'

describe Krikri::Provider do
  let(:local_name) { '123' }

  let(:provider) do
    provider = Krikri::Provider.new(local_name)
    provider.providedLabel = "moomin"
    provider
  end

  let(:agg) do
    a = build(:aggregation, :provider => provider)
    a.set_subject! 'moomin'
    a
  end

  shared_context 'with indexed item' do
    before do
      agg.save
      indexer = Krikri::IndexService.new
      indexer.add(agg.to_jsonld['@graph'].first.to_json)
      indexer.commit
    end

    after do
      indexer = Krikri::IndexService.new
      indexer.delete_by_query(['*:*'])
      indexer.commit
    end
  end

  describe '.all' do
    it 'with no items is empty' do
      expect(described_class.all).to be_empty
    end

    context 'with item' do
      include_context 'with indexed item'

      it 'returns all items' do
        # todo: ActiveTriples::Resource equality needs work
        expect(described_class.all.map(&:rdf_subject))
          .to contain_exactly provider.rdf_subject
      end
    end
  end

  describe '.find' do
    include_context 'with indexed item'

    it 'finds the provider' do
      expect(described_class.find(local_name)).to eq provider
    end

    it 'populates graph' do
      expect(described_class.find(local_name).count)
        .to eq provider.count
    end

    it 'returns property values' do
      expect(described_class.find(local_name).providedLabel)
        .to eq provider.providedLabel
    end
  end
end
