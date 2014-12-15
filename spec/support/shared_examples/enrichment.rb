
shared_examples 'an enrichment' do
  it 'is an enrichment' do
    expect(subject).to be_a Krikri::Enrichment
  end
end
