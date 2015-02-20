shared_examples 'a parser with oai headers' do
  describe '#header' do
    it 'has a header' do
      expect(subject.header).to be_a Krikri::Parser::ValueArray
    end

    it 'has children' do
      expect(subject.header.first.children)
        .to include('xmlns:identifier', 'xmlns:datestamp', 'xmlns:setSpec')
    end
  end
end
