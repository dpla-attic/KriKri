
##
# Shared context for queries that find entities (i.e. records) affected
# by an Activity.
#
# See 'provenance queries' shared context
#
shared_context 'entities query' do
  # aggregation comes from lib/dpla/map/factories.rb in DPLA::MAP
  let(:aggregation) { build(:aggregation) }

  before do
    DatabaseCleaner.clean_with(:truncation)
    create(:krikri_harvest_activity)
    create(:krikri_mapping_activity)
    create(:krikri_enrichment_activity)
    allow(DPLA::MAP::Aggregation).to receive(:new)
      .with(solution.record.to_s)
      .and_return(aggregation)
    aggregation.set_subject!('aggregation_uri')
    allow(aggregation).to receive(:get).and_return(true)
  end
end
