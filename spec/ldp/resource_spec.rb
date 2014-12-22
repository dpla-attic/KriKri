require 'spec_helper'

describe Krikri::LDP::Resource do
  before do
    # a dummy resource
    class DummyResource; include Krikri::LDP::Resource; end
  end

  after do
    Object.send(:remove_const, 'DummyResource')
  end

  subject { DummyResource.new }

  it 'has a connection' do
    expect(subject.ldp_connection).to be_a Faraday::Connection
  end

  context 'with subject' do
    before do
      # add required interface to DummyResourcey
      class DummyResource
        def rdf_subject
          RDF::URI(File.join(Krikri::Settings['marmotta']['ldp'],
                             '/moomin-papa'))
        end
      end
    end

    after do
      RDF::Marmotta.new(Krikri::Settings['marmotta']['base']).clear!
    end

    describe '#save' do
      let(:response) { subject.save }

      it 'saves resource' do
        expect(response.env.status).to eq 201
      end

      it 'saved resource has exact uri' do
        expect(response.env.response_headers['location'])
          .to eq subject.rdf_subject.to_s
      end

      # Sleep makes this test pretty much useless.
      # The test, cache, and/or marmotta needs more work for thread safety
      xit 'is (sort of) idempotent' do
        subject.save
        sleep(0.8)
        subject_clone = subject.dup
        subject.save('')
        expect { subject_clone.save }
          .to raise_error(Faraday::ClientError,
                          'the server responded with status 412')
      end
    end

    describe '#http_head' do
      it 'raises 404 when resource is not present' do
        expect { subject.http_head }.to raise_error Faraday::ResourceNotFound
      end

      it 'returns a hash of headers' do
        subject.save
        expect(subject.http_head.keys).to include 'location'
      end

      it 'does not send request when cached' do
        subject.save
        allow(subject).to receive(:make_request)
        expect(subject).not_to receive(:make_request)
        subject.http_head
      end
    end

    describe '#get' do
      before { subject.save }
      let(:response) { subject.get }

      it 'gets the resource' do
        expect(response.env.status).to eq 200
      end

      it 'does not send request when cached' do
        response
        allow(subject).to receive(:make_request)
        expect(subject).not_to receive(:make_request)
        subject.get
      end

      it 'response includes body' do
        expect(subject.get.env.body).to be_a String
      end

      xit 'sets content to response body' do
        expect(content).to eq response.env.body
      end
    end

    describe '#delete!' do
      context 'before saved' do
        it 'raises an error' do
          expect { subject.delete! }
            .to raise_error('Cannot delete ' \
                            "#{subject.rdf_subject}, does not exist.")
        end
      end

      context 'with saved object' do
        before { subject.save }

        it 'deletes object from LDP endpoint' do
          expect(subject.delete!.env.status).to eq 204
        end

        it 'no longer exists' do
          subject.delete!
          expect(subject).not_to exist
        end
      end
    end

    describe '#exist?' do
      it "knows it doesn't exist" do
        expect(subject).not_to exist
      end

      it 'knows when it does exist' do
        subject.save
        expect(subject).to exist
      end
    end

    describe '#etag' do
      context 'before saved' do
        it 'returns nil' do
          expect(subject.etag).to be_nil
        end
      end

      context 'with etag' do
        before { subject.save }

        it 'returns an etag' do
          expect(subject.etag).to be_a String
        end
      end
    end
  end
end
