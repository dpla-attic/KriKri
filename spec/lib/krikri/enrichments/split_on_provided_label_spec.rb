require 'spec_helper'

describe Krikri::Enrichments::SplitOnProvidedLabel do
  it_behaves_like 'a field enrichment'

  describe '#enrich_value' do
    let(:resource) { DPLA::MAP::Agent.new }

    it 'skips non-resource values' do
      date = Date.today
      expect(subject.enrich_value(date)).to eq date
    end

    it 'skips values that do not respond to providedLabel' do
      resource = ActiveTriples::Resource.new
      expect(subject.enrich_value(resource)).to eq resource
    end

    it 'leaves an existing single providedLabel as is' do
      resource.providedLabel = 'moomin'
      expect(subject.enrich_value(resource)).to eq resource
    end

    it 'leaves existing non-providedLabel values in place' do
      close_match = 'Moomin'

      resource.providedLabel = ['moomin', 'moominmama']
      resource.closeMatch    = close_match

      expect(subject.enrich_value(resource).map(&:closeMatch))
        .to contain_exactly([close_match], [])
    end

    it 'splits multiple provided ' do
      labels                 = ['moomin', 'moominmama']
      resource.providedLabel = labels

      expect(subject.enrich_value(resource).map(&:providedLabel))
        .to contain_exactly([labels.first], [labels.last])
    end
  end
end
