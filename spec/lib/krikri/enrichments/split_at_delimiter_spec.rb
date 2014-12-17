require 'spec_helper'

describe Krikri::Enrichments::SplitAtDelimiter do
  it_behaves_like 'an enrichment'

  describe '#enrich_value' do
    it 'skips unsplittable values' do
      date = Date.today
      expect(subject.enrich_value(date)).to eq date
    end

    it 'strips empty fields' do
      expect(subject.enrich_value('moomin; moomin mama; moomin papa'))
        .to contain_exactly('moomin', 'moomin mama', 'moomin papa')
    end
  end
end
