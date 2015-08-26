require 'spec_helper'

describe Krikri::MapCrosswalk do
  subject { build(:aggregation)  }

  describe '#to_3_1_json' do
    it 'builds a hash' do
      result = double(:hash)
      allow(described_class::CrosswalkHashBuilder)
        .to receive(:build).with(subject).and_return result

      expect(subject.to_3_1_json).to eq result
    end
  end
end

describe Krikri::MapCrosswalk::CrosswalkHashBuilder do
  subject { described_class.new(aggregation) }
  let(:aggregation) { build(:aggregation) }

  it 'raises an error with a bnode' do
    expect { subject.build }.to raise_error
  end

  context 'with a uri' do
    before { aggregation.set_subject!('moomin') }

    it 'builds a hash' do
      expect(subject.build).to be_a Hash
    end

    it 'updates cached hash' do
      expect { subject.build }.to change { subject.hash }
    end

    context 'with hash built' do
      before { subject.build }

      it 'has a ingest type' do
        expect(subject.hash[:ingestType]).to eq 'item'
      end

      it 'has an ingest sequenece' do
        expect(subject.hash[:ingestionSequence]).to be_an_integer
      end

      it 'has a uri' do
        expect(subject.hash[:@id]).to eq 'http://dp.la/api/items/moomin'
      end

      it 'has a sourceResource' do
        expect(subject.hash[:sourceResource][:@id])
          .to eq 'http://dp.la/api/items/moomin#sourceResource'
      end

      it 'has prefLabels' do
        expect(subject.hash[:sourceResource][:@id])
          .to eq 'http://dp.la/api/items/moomin#sourceResource'
      end

      context 'with prefLabel' do
        before do
          aggregation.sourceResource.first.language.first.prefLabel = label
          subject.build
        end
        
        let(:label) { 'en' }
        
        it 'uses prefLabel' do
          expect(subject.hash[:sourceResource][:language]).to contain_exactly label
        end
      end

      context 'with mistyped values' do
        before do
          aggregation.hasView = 'NOT REAL'
          aggregation.sourceResource.first.genre << 'not a resource!'
          subject.build
        end

        it 'includes expected strings' do
          expect(subject.hash[:sourceResource][:genre])
            .to include 'not a resource!'
        end

        it 'excludes expected objects' do
          expect(subject.hash[:hasView]).to be_nil
        end
      end
    end
  end
end
