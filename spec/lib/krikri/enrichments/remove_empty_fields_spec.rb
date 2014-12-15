require 'spec_helper'

describe Krikri::Enrichments::RemoveEmptyFields do
  it_behaves_like 'an enrichment'

  let(:aggregation) { build(:aggregation) }

  describe '#enrich' do
    before { aggregation.aggregatedCHO.first.title = '' }

    it '' do
      expect(subject.enrich(aggregation).aggregatedCHO.first.title).to eq []
    end
  end
end
