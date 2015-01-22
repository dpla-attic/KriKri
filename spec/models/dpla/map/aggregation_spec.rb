require 'spec_helper'

describe DPLA::MAP::Aggregation do
  it_behaves_like 'an LDP RDFSource'

  include_context 'clear repository'

  describe '#mint_uri!' do
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
    end

    context 'with originalRecord' do
      include_examples 'sets to seed'

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
        before do
          subject.originalRecord << RDF::Node.new
        end

        it 'raises an error' do
          expect { subject.mint_id! }.to raise_error
        end
      end
    end
  end
end
