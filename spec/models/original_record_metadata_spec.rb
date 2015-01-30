require 'spec_helper'

describe Krikri::OriginalRecordMetadata do
  it_behaves_like 'an LDP RDFSource'

  include_context 'clear repository'

  context 'when created with an OriginalRecord' do
    subject { record.rdf_source }
    let(:agent_uri) { RDF::URI('http://example.org/agent/1') }


    let(:record) do
      Krikri::OriginalRecord.build('mummi', '')
    end

    before { record.save; subject.get }

    it 'has created date' do
      expect(subject.created).to contain_exactly(an_instance_of DateTime)
    end

    it 'has modified date' do
      expect(subject.modified).to contain_exactly(an_instance_of DateTime)
    end

    it 'has a format' do
      expect(subject.hasFormat.map(&:rdf_subject))
        .to contain_exactly(record.rdf_subject)
    end

    it 'accepts an agent' do
      subject.wasGeneratedBy = agent_uri
      expect(subject.wasGeneratedBy.map(&:rdf_subject))
        .to contain_exactly(agent_uri)
    end
  end
end
