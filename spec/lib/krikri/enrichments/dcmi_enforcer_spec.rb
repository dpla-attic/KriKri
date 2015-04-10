require 'spec_helper'

describe Krikri::Enrichments::DcmiEnforcer do
  it_behaves_like 'a field enrichment'

  it 'keeps DCMI Type values' do
    value = DPLA::MAP::Controlled::DCMIType.new('Image')
    expect(subject.enrich_value(value)).to eq value
  end

  it 'removes invalid DCMI Type values' do
    value = DPLA::MAP::Controlled::DCMIType.new
    expect(subject.enrich_value(value)).to be_nil
  end

  it 'removes string values' do
    value = 'moomin'
    expect(subject.enrich_value(value)).to be_nil
  end

  it 'removes other values' do
    value = Date.today
    expect(subject.enrich_value(value)).to be_nil
  end
end
