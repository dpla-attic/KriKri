require 'spec_helper'

describe Krikri::OriginalRecord do
  it_behaves_like 'an LDP Resource'

  include_context 'clear repository'

  shared_context 'serializations' do
    it 'has a string format' do
      expect(subject.to_s).to be_a String
    end

    it 'string format matches input' do
      expect(subject.to_s).to eq record.to_s
    end
  end

  subject { described_class.build(identifier, record) }
  let(:record) { '123' }
  let(:identifier) { 'id_1234' }

  describe '#new' do
    it 'sets #local_name' do
      expect(described_class.new(identifier).local_name).to eq identifier
    end

    it 'raises error if there are invalid characters' do
      expect { described_class.new("#{identifier}/12") }
        .to raise_error ArgumentError
    end
  end

  describe '#load' do
    context 'existing record' do
      before { subject.save }

      it 'loads resource with correct content' do
        expect(described_class.load(identifier).content).to eq subject.content
      end

      it 'loads resource with correct content_type' do
        expect(described_class.load(identifier).content_type)
          .to eq subject.content_type
      end

      context 'when passed a fully qualified URI' do
        let(:uri) { subject.rdf_source.rdf_subject }

        it 'raises error if the wrong base uri is used' do
          expect { described_class.new('http://example.org/12') }
            .to raise_error ArgumentError
        end

        it 'sets #local_name' do
          expect(described_class.load(uri).local_name).to eq identifier
        end
      end
    end
  end

  describe '#build' do
    it 'raises an error if not passed a file or string' do
      expect { described_class.build(identifier, [1, 2, 3]) }
        .to raise_error ArgumentError
    end

    it 'accepts a content_type' do
      ctype = 'application/xml'
      expect(described_class.build(identifier, record, ctype).content_type)
        .to eq ctype
    end

    it 'builds same record for same id' do
      subject.save
      subject_clone = described_class.build(identifier, '').reload
      expect(subject_clone).to be == subject
    end
  end

  describe '#==' do
    let(:other) { subject.clone }

    it 'gives equality for equivalent objects' do
      expect(subject == other).to be true
    end

    shared_examples 'is false' do
      it 'compares false' do
        expect(subject == other).to be false
      end
    end

    context 'when comparing wrong type' do
      let(:other) { Object.new }
      include_examples 'is false'
    end

    context 'when one object is saved' do
      before { other.save }
      include_examples 'is false'
    end

    context 'when local name is different' do
      before { other.local_name = 'new_mummi' }
      include_examples 'is false'
    end

    context 'content is different' do
      before { other.content = 'new_mummi_content' }
      include_examples 'is false'
    end

    context 'content_type is different' do
      before { other.content_type = 'application/xml+moomin' }
      include_examples 'is false'
    end
  end

  context 'with string input' do
    let(:record) { '<record><title>Comet in Moominland</title></record>' }

    include_context 'serializations'
  end

  describe '#save' do
    let(:result) { subject.save }

    it 'updates' do
      result
      subject.content = 'abc'
      subject.save
      expect(subject.get.env.body).to eq 'abc'
    end

    it 'updates existing record' do
      result
      new_subject = described_class.load(identifier)
      new_subject.content = 'abc'
      new_subject.save
      subject.reload
      expect(subject.content).to eq 'abc'
    end

    it 'sets rdf_subject' do
      result
      # This makes marmotta-based assumptions, there's no reason an RDFSource
      # should share a URI base with LDP-NR's it describes. It seems like a
      # valid check, anyway.
      expect(subject.rdf_subject)
        .to start_with "#{subject.rdf_source.rdf_subject}."
    end

    context 'with activity uri' do
      before do
        subject.save(activity_uri)
      end

      let(:activity_uri) { RDF::URI('http://example.org/prov/activity/123') }

      it 'sets wasGeneratedBy on #rdf_source' do
        expect(subject.rdf_source.wasGeneratedBy.map(&:rdf_subject))
          .to contain_exactly(activity_uri)
      end
    end
  end

  describe '#reload' do
    it 'reloads content' do
      subject.save
      subject.content = 'abc'
      subject.reload
      expect(subject.content).to eq '123'
    end

    it 'reloads content_type' do
      subject.save
      ctype = subject.content_type
      subject.content_type = 'application/xml'
      subject.reload
      expect(subject.content_type).to eq ctype
    end
  end

  describe '#rdf_source' do
    it 'is a uri' do
      expect(subject.rdf_source).to be_a Krikri::OriginalRecordMetadata
    end
  end
end
