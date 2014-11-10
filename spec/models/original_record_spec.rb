require 'spec_helper'

describe Krikri::OriginalRecord do

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

  after do
    RDF::Marmotta.new(Krikri::Settings['marmotta']['base']).clear!
  end

  describe '#new' do
    context 'existing record' do
      before { subject.save }

      it 'loads resource with correct #local_name' do
        expect(described_class.new(identifier).local_name).to eq identifier
      end

      it 'loads resource with correct content' do
        expect(described_class.new(identifier).content).to eq subject.content
      end

      it 'loads resource with correct content_type' do
        expect(described_class.new(identifier).content_type)
          .to eq subject.content_type
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

  context 'with string input' do
    let(:record) { '<record><title>Comet in Moominland</title></record>' }

    include_context 'serializations'
  end

  describe '#save' do
    let(:result) { subject.save }

    it 'saves' do
      expect(result).to eq true
    end

    it 'updates' do
      result
      subject.content = 'abc'
      subject.save
      expect(subject.get.env.body).to eq 'abc'
    end

    it 'updates existing record' do
      result
      new_subject = described_class.new(identifier)
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
      expect(subject.rdf_subject).to start_with "#{subject.rdf_source}."
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
      subject.content_type = 'application/xml'
      subject.reload
      expect(subject.content_type).to eq 'application/octet-stream'
    end
  end

  describe '#rdf_source' do
    it 'is a uri' do
      expect(subject.rdf_source).to be_a RDF::URI
    end
  end
end
