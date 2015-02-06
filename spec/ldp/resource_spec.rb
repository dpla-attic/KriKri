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
          RDF::URI(Krikri::Settings['marmotta']['ldp']) / 'moomin-papa'
        end
      end
    end

    after do
      RDF::Marmotta.new(Krikri::Settings['marmotta']['base']).clear!
    end

    context 'with bad header' do
      it do
        error = Net::HTTPBadResponse.new("alue\" : \"1\"")
        expect_any_instance_of(Faraday::Adapter::NetHttp)
          .to receive(:perform_request).at_least(4).times.and_raise(error)
        expect { subject.get }.to raise_error
      end
    end

    context 'without marmotta connection' do
      before do
        @real_connection = Krikri::Settings['marmotta']['ldp']
        Krikri::Settings['marmotta']['ldp'] = 'http://localhost:4/marmotta/'
      end

      after do
        Krikri::Settings['marmotta']['ldp'] = @real_connection
      end

      it 'raises an appropriate error' do
        expect { subject.exists? }.to raise_error Faraday::ConnectionFailed
      end
    end
  end
end
