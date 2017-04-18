
##
# Shared context for activities that enumerate their generated entities.
#
# To use, define in your example:
#   - generator_uri [String] URI that corresponds to the ID of your activity
#
shared_context 'provenance queries' do
  let(:uri)           { double('result uri') }
  let(:query)         { double('RDF::Query') }
  let(:solution)      { double('RDF::Query::Solution') }
  let(:solution_enum) { Enumerator.new { |e| e.yield solution } }

  before do
    # query and solution mocks
    allow(query).to    receive(:execute).and_return([solution])
    allow(query).to    receive(:solutions).and_return(solution_enum)
    allow(query).to    receive(:each_solution).and_return(solution_enum)
    allow(solution).to receive(:record).and_return(uri)

    # find by activity query
    allow(Krikri::ProvenanceQueryClient).to receive(:find_by_activity)
      .with(RDF::URI(generator_uri), false).and_return(query)

    # count by activity query
    allow(Krikri::ProvenanceQueryClient).to receive(:count_by_activity)
      .with(RDF::URI(generator_uri), false).and_return(1)
  end
end
