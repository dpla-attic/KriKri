require 'spec_helper'

describe DPLA::MAP::Aggregation do
  it_behaves_like 'an LDP RDFSource'

  let(:empty_or) { [] }
  let(:blanknode_or) { [RDF::Node.new] }
  let(:empty_msg) do
    "#{subject.dpla_id} has an empty originalRecord"
  end
  let(:blanknode_msg) do
    "#{subject.dpla_id} has a blank node for its originalRecord"
  end

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

    context 'when originalRecord is empty' do
      before do
        allow(subject).to receive(:originalRecord).and_return(empty_or)
      end

      it 'raises a NameError' do
        expect { subject.mint_id! }.to raise_error(NameError, empty_msg)
      end
    end

    context 'when originalRecord returns a blank node' do
      before do
        allow(subject).to receive(:originalRecord).and_return(blanknode_or)
      end

      it 'raises a NameError' do
        expect { subject.mint_id! }.to raise_error(NameError, blanknode_msg)
      end
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

    context 'when originalRecord is empty' do
      before do
        allow(subject).to receive(:originalRecord).and_return(empty_or)
      end
      it 'raises a NameError' do
        expect { subject.original_record }.to raise_error(NameError, empty_msg)
      end
    end

    context 'when originalRecord returns a blank node' do
      before do
        allow(subject).to receive(:originalRecord).and_return(blanknode_or)
      end
      it 'raises a NameError' do
        expect { subject.original_record }
          .to raise_error(NameError, blanknode_msg)
      end
    end
  end
end
