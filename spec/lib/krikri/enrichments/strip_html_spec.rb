require 'spec_helper'

describe Krikri::Enrichments::StripHtml do
  it_behaves_like 'a field enrichment'

  let(:start_value) { '<html>Moomin <i><b>Valley</i></b>' }
  let(:end_value) { 'Moomin Valley' }

  it 'skips non-string values' do
    date = Date.today
    expect(subject.enrich_value(date)).to eq date
  end

  it 'removes html tags from fields' do
    expect(subject.enrich_value(start_value))
      .to eq end_value
  end
end
