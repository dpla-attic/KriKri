require 'spec_helper'

describe Krikri::SearchIndexDocument, type: :model do

  subject do
    Krikri::SearchIndexDocument.new(id: '0123')
  end

  it 'is a SolrDocument' do
    expect(subject).to be_a SolrDocument
  end

  describe '#to_param' do
    it 'uses local name instead of full item uri for routes' do
      item_uri = 'http://dp.la/marmotta/ldp/items/123ab'
      doc = Krikri::SearchIndexDocument.new(id: item_uri)
      expect(doc.to_param).to eq('123ab')
    end
  end

  describe '#aggregation' do

    it 'creates a DPLA::MAP::Aggregation with its id' do
      expect(DPLA::MAP::Aggregation).to receive(:new).with('0123')
        .and_return(DPLA::MAP::Aggregation.new('0123'))
      subject.aggregation
    end

    context 'with existing Marmotta record' do

      before :each do
        allow_any_instance_of(DPLA::MAP::Aggregation).to receive(:exists?)
          .and_return(true)
      end

      it 'gets data from Marmotta' do
        expect_any_instance_of(DPLA::MAP::Aggregation).to receive(:get)
        subject.aggregation
      end

      it 'returns a DPLA::MAP::Aggregation' do
        allow_any_instance_of(DPLA::MAP::Aggregation).to receive(:get)
        expect(subject.aggregation)
          .to be_instance_of(DPLA::MAP::Aggregation)
      end
    end

    context 'without existing Marmotta record' do

      before :each do
        allow_any_instance_of(DPLA::MAP::Aggregation).to receive(:exists?)
          .and_return(false)
      end

      it 'returns nil' do
        expect(subject.aggregation).to be_nil
      end
    end
  end
end
