shared_context 'provenance queries' do
  let(:query) { double('RDF::Query') }
  let(:solution) { double('RDF::Solution') }
  let(:uri) { double('result uri') }

  before do
    allow(Krikri::ProvenanceQueryClient).to receive(:find_by_activity)
      .with(generator_uri).and_return(query)
    allow(query).to receive(:execute).and_return([solution])
    allow(solution).to receive(:record).and_return(uri)
  end
end
