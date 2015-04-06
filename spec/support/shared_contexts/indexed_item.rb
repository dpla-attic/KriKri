shared_context 'with indexed item' do
  include_context 'clear repository'

  before do
    clear_search_index
    indexer = Krikri::QASearchIndex.new
    records.each { |rec| indexer.add rec.to_jsonld['@graph'].first }
    indexer.commit
  end

  after do
    clear_search_index
  end

  let(:records) { [agg] }

  let(:agg) do
    a = build(:aggregation)
    a.provider = provider
    a.set_subject! 'moomin'
    a
  end

  let(:provider) do
    build(:krikri_provider,
          rdf_subject: 'moomin_valley',
          label: 'moomin valley')
  end
end

shared_context 'with missing values' do
  include_context 'with indexed item' do
    let(:records) { [agg, empty, empty_new_provider] }

    let(:empty) do
      aggregation = build(:aggregation, provider: provider, sourceResource: nil)
      aggregation.set_subject! 'empty'
      aggregation
    end

    let(:empty_new_provider) do
      aggregation = build(:aggregation,
                          provider: RDF::URI('http://example.com/fake'),
                          sourceResource: nil)
      aggregation.set_subject! 'empty_new_provider'
      aggregation
    end
  end
end
