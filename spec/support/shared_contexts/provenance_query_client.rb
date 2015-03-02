shared_context 'provenance queries' do
  let(:query) { double('RDF::Query') }
  let(:solution) { double('RDF::Query::Solution') }
  let(:solution_enum) do
    Enumerator.new do |e|
      e.yield solution
    end
  end
  let(:uri) { double('result uri') }

  before do
    allow(Krikri::ProvenanceQueryClient).to receive(:find_by_activity)
      .with(generator_uri).and_return(query)
    allow(query).to receive(:execute).and_return([solution])
    allow(query).to receive(:each_solution).and_return(solution_enum)
    allow(solution).to receive(:record).and_return(uri)
  end
end
