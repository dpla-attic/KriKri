require 'spec_helper'

describe Krikri::Enrichments::RemoveEmptyFields do
  it_behaves_like 'an enrichment'

  describe '#enrich_value' do
    it 'strips empty fields' do
      expect(subject.enrich_value('')).to be_nil
    end

    it 'leaves non-empty fields unaltered' do
      expect(subject.enrich_value('moomin')).to eq 'moomin'
    end
  end
end
