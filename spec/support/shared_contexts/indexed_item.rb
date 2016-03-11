shared_context 'with indexed item' do
  include_context 'clear repository'

  before do
    clear_search_index
    indexer = Krikri::QASearchIndex.new
    records.each { |rec| indexer.add rec.to_jsonld['@graph'].first }
    indexer.commit
  end

  after { clear_search_index }

  let(:records) { [agg] }

  let(:agg) do
    provider_agent = provider.agent
    provider_agent.label = provider.name

    aggregation = build(:aggregation, provider: provider_agent)
    aggregation.set_subject! 'moomin'
    aggregation
  end

  let(:provider) { build(:krikri_provider) }
end

shared_context 'with missing values' do
  include_context 'with indexed item' do
    let(:records) { [agg, empty, empty_new_provider] }

    let(:empty) do
      provider_agent = provider.agent
      provider_agent.label = provider.name

      aggregation = build(:aggregation, 
                          provider: provider_agent, 
                          sourceResource: nil)
      aggregation.set_subject! 'empty'
      aggregation
    end

    let(:empty_new_provider) do
      provider_agent = build(:krikri_provider, 
                             rdf_subject: 'http://example.com/fake').agent

      aggregation = build(:aggregation,
                          provider: provider_agent,
                          sourceResource: nil)
      aggregation.set_subject! 'empty_new_provider'
      aggregation
    end
  end
end
