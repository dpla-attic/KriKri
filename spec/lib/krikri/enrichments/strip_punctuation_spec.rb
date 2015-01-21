require 'spec_helper'

describe Krikri::Enrichments::StripPunctuation do
  it_behaves_like 'a field enrichment'

  describe '#enrich_value' do
    let(:start_value) { "\tmoominpapa;... !@#$ moominmama  " }
    let(:end_value) { "\tmoominpapa  moominmama  " }

    it 'skips non-string values' do
      date = Date.today
      expect(subject.enrich_value(date)).to eq date
    end

    it 'strips extra whitspace from fields' do
      expect(subject.enrich_value(start_value)).to eq end_value
    end

    it 'leaves other fields unaltered' do
      expect(subject.enrich_value(end_value)).to eq end_value
    end
  end
end
