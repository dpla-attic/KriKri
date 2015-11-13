shared_examples 'a MARC XML harvester' do
  it_behaves_like 'a harvester'

  describe 'max records' do
    let(:max) { 2 }
  
    it 'stops harvesting at max records count' do
      expect(subject.records).to have(2).items
    end
  end

  describe '#records' do
    it 'returns records with xml content type' do
      subject.records.each do |rec|
        expect(rec).to have_content_type 'text/xml'
      end
    end
  end
end
