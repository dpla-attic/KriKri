require 'spec_helper'

describe Krikri::Enrichments::StripWhitespace do
  it_behaves_like 'a field enrichment'

  describe '#enrich_value' do
    let(:start_value) { "\tmoominpapa  \t\r  \nmoominmama  " }
    let(:end_value) { 'moominpapa moominmama' }

    it 'skips non-string values' do
      date = Date.today
      expect(subject.enrich_value(date)).to eq date
    end

    it 'strips extra whitespace from fields' do
      expect(subject.enrich_value(start_value)).to eq end_value
    end

    it 'leaves other fields unaltered' do
      expect(subject.enrich_value(end_value)).to eq end_value
    end
  end
end
