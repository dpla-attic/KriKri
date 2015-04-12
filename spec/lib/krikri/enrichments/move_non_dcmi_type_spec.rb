require 'spec_helper'

describe Krikri::Enrichments::MoveNonDcmiType do
  it_behaves_like 'a generic enrichment'

  it 'returns strings as found' do
    string = 'moomin'
    expect(subject.enrich_value(string)).to eq string
  end

  it 'returns typed data as found' do
    date = Date.today
    expect(subject.enrich_value(date)).to eq date
  end

  it 'returns Resources as found' do
    resource = ActiveTriples::Resource.new
    expect(subject.enrich_value(resource)).to eq resource
  end

  it 'returns nil for DCMI Type values' do
    resource = DPLA::MAP::Controlled::DCMIType.new
    expect(subject.enrich_value(resource)).to be_nil
  end
end
