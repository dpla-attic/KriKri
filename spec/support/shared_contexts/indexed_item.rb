shared_context 'with indexed item' do
  include_context 'clear repository'

  before do
    clear_search_index
    indexer = Krikri::QASearchIndex.new
    indexer.add agg.to_jsonld['@graph'].first
    indexer.commit
  end

  after do
    clear_search_index
  end

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
