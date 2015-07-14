require 'spec_helper'

describe Krikri::Enrichments::CreatePrefLabelFromProvided do
  it_behaves_like 'a field enrichment'

  describe '#enrich_value' do
    let(:resource) { DPLA::MAP::Agent.new }

    it 'skips non-Resource' do
      date = Date.today
      expect(subject.enrich_value(date)).to eq date
    end

    it 'skips values that do not respond to providedLabel' do
      resource = ActiveTriples::Resource.new
      expect { subject.enrich_value(resource) }
        .not_to change { resource.get_values(RDF::SKOS.prefLabel) }.from([])
    end

    it 'skips values that have no providedLabel' do
      expect { subject.enrich_value(resource) }
        .not_to change { resource.label }.from([])
    end

    it 'skips values that aready have a prefLabel' do
      resource.providedLabel = 'moomin'
      resource.label = 'moomintroll'
      expect { subject.enrich_value(resource) }
        .not_to change { resource.label }
                 .from(a_collection_containing_exactly('moomintroll'))
    end

    it 'copies providedLabel to prefLabel' do
      resource.label = nil
      resource.providedLabel = 'moomintroll'
      subject.enrich_value(resource)
      expect(resource.label).to contain_exactly 'moomintroll'
      expect(resource.providedLabel).to contain_exactly 'moomintroll'
    end

    it 'copies first providedLabel to prefLabel' do
      resource.label = nil
      resource.providedLabel << 'moomintroll'
      resource.providedLabel << 'snorkmaiden'
      subject.enrich_value(resource)

      expect(resource.label).to contain_exactly 'moomintroll'
      expect(resource.providedLabel)
        .to contain_exactly('moomintroll', 'snorkmaiden')
    end
  end
end
