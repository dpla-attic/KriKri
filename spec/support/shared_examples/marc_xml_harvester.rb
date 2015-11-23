shared_examples 'a MARC XML harvester' do
  it_behaves_like 'a harvester'

  describe '#records' do
    it 'returns records with xml content type' do
      subject.records.each do |rec|
        expect(rec).to have_content_type 'text/xml'
      end
    end
  end
end
