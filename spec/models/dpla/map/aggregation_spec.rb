require 'spec_helper'

describe DPLA::MAP::Aggregation do
  it_behaves_like 'an LDP RDFSource'

  include_context 'clear repository'

  describe '#mint_uri!' do
    shared_examples 'sets fragment URI for sourceResource' do
      let(:agg_with_sr) { build(:aggregation) }

      it 'sets fragment URI for sourceResource' do
        agg_with_sr.mint_id!
        expect(agg_with_sr.sourceResource.first.rdf_subject)
          .to eq RDF::URI(agg_with_sr.rdf_subject) / '#sourceResource'
      end
    end

    shared_examples 'sets to seed' do
      it 'sets URI' do
        subject.mint_id!('uri_seed')
        expect(subject.rdf_subject)
          .to eq RDF::URI(subject.class.base_uri) / 'uri_seed'
      end
    end

    shared_examples 'random hash' do
      it 'mints random hash' do
        expect(SecureRandom).to receive(:hex).and_return('abcd1234')
        subject.mint_id!
        expect(subject.rdf_subject)
          .to eq RDF::URI(subject.class.base_uri) / 'abcd1234'
      end
    end

    context 'without originalRecord' do
      include_examples 'sets to seed'
      include_examples 'random hash'
      include_examples 'sets fragment URI for sourceResource'
    end

    context 'with originalRecord' do
      include_examples 'sets to seed'
      include_examples 'sets fragment URI for sourceResource'

      before do
        subject.originalRecord = or_uri
      end

      let(:local_name) { '123' }
      let(:or_uri) do
        RDF::URI('http://example.org/ldp/resource/') / local_name + '.xml'
      end

      it 'mints a URI' do
        subject.mint_id!
        expect(subject.rdf_subject)
          .to eq RDF::URI(subject.class.base_uri) / local_name
      end

      context 'as a bnode' do
        before do
          subject.originalRecord = RDF::Node.new
        end

        include_examples 'random hash'
      end

      context 'with more than one originalRecord' do
        before { subject.originalRecord << RDF::Node.new }

        it 'raises an error' do
          expect { subject.mint_id! }
            .to raise_error start_with("#{subject} has more than " \
                                       'one OriginalRecord')
        end
      end
    end
  end

  describe '#dpla_id' do
    it 'is nil for a bnode' do
      expect(subject.dpla_id).to be_nil
    end

    it 'matches local name in URI' do
      ln = '123'
      subject.set_subject!(ln)
      
      expect(subject.dpla_id).to eq ln
    end

    it 'raises an error when a non-dpla uri is present' do
      bad_uri = 'http://example.org/not-dpla/moomin'
      subject.set_subject!(bad_uri)
      
      expect { subject.dpla_id }
        .to raise_error Krikri::Engine::NamespaceError
    end
  end

  describe '#original_record' do

    context 'with original record' do
      let(:original_record) { Krikri::OriginalRecord.build('123', 'abc') }

      before do
        original_record.save
        subject.originalRecord = ActiveTriples::Resource
          .new(original_record.rdf_subject.to_s)
      end

      it 'returns OriginalRecord object' do
        expect(subject.original_record).to eq(original_record)
      end
    end

    context 'without original record' do
      it 'raises an error' do
        expect { subject.original_record }.to raise_error NameError
      end
    end
  end
end
