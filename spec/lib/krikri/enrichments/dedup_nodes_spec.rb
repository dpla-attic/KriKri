require 'spec_helper'

describe Krikri::Enrichments::DedupNodes do
  it_behaves_like 'a field enrichment'

  let(:value) { build(:source_resource, creator: agents) }

  let(:agents) do
    [ build(:agent),
      agent_with_uri,
      'moomin',
      ActiveTriples::Resource.new('http://example.org'),
      Date.today ]
  end

  let(:agent_with_uri) do
    agent = build(:agent)
    agent.set_subject! 'http://example.org/moomin'
    agent
  end

  context 'with duplicate values' do
    before { agents << build(:agent) }

    it 'returns original node' do
      expect(subject.enrich_value(value).rdf_subject).to eq value.rdf_subject
    end

    it 'removes duplicate nodes' do
      expect(subject.enrich_value(value).creator)
        .to contain_exactly(*agents[0..-2])
    end

    it 'ignores other nodes' do
      expect(subject.enrich_value(value).contributor)
        .to contain_exactly(*value.contributor)
    end
  end

  it 'returns an isomorphic graph' do
    expect(subject.enrich_value(value)).to be_isomorphic_with value
  end

  it 'leaves literal values unaltered' do
    expect(subject.enrich_value('moomin')).to eq 'moomin'
  end
end
