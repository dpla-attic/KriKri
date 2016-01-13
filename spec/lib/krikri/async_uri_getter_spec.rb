require 'spec_helper'

# Adding this to make sure the exception classes are available no matter which
# order the tests run in.
require 'faraday_middleware/response/follow_redirects'

describe Krikri::AsyncUriGetter do
  subject { described_class.new }

  let(:test_uri) { URI.parse('http://example.com') }

  it 'fetches URLs from a new thread' do
    main_thread = Thread.current

    # extra check to avoid succeeding with a false positive
    test_hit = false
    WebMock.after_request do |request_signature, _|
      if request_signature.uri.to_s.start_with?(test_uri.to_s)
        test_hit = true
        expect(Thread.current).to_not be(main_thread)
      end
    end
  end

  it 'retries on request failure' do
    stub_request(:get, test_uri)
      .to_raise(Faraday::ConnectionFailed)
      .to_return(:status => 200, :body => 'No problem!', :headers => {})

    subject.add_request(uri: test_uri).with_response do |r|
      expect(r.status).to eq(200)
      expect(r.body).to eq('No problem!')
    end
  end

  it 'sends supplied HTTP headers with the request' do
    test_headers = { 'X-Test-Header' => 'true' }

    stub_request(:get, test_uri)
      .with(:headers => test_headers)
      .to_return(status: 200, body: 'OK')

    subject.add_request(uri: test_uri, headers: test_headers).join
  end

  it 'follows HTTP redirects if requested' do
    stub_request(:get, test_uri)
      .to_return(status: 301, headers: { 'Location' => test_uri.to_s })
      .to_return(status: 200, body: 'OK')

    r = subject.add_request(uri: test_uri, opts: { follow_redirects: true })

    r.with_response do |response|
      expect(response.body).to eq('OK')
    end
  end

  it 'returns the HTTP redirect response if requested' do
    stub_request(:get, test_uri)
      .to_return(status: 301, headers: { 'Location' => test_uri.to_s })

    r = subject.add_request(uri: test_uri, opts: { follow_redirects: false })

    r.with_response do |response|
      expect(response.status).to eq(301)
      expect(response.headers['Location']).to eq(test_uri.to_s)
    end
  end

  it 'aborts when the redirect limit is hit' do
    stub_request(:get, test_uri)
      .to_return(status: 301, headers: { 'Location' => test_uri.to_s })

    r = subject.add_request(uri: test_uri, opts: { follow_redirects: true })

    expect { r.join }
      .to raise_error(FaradayMiddleware::RedirectLimitReached)
  end

  it 'passes HTTP error responses to #with_response as normal' do
    stub_request(:get, test_uri)
      .to_return(status: 500, body: 'Something terrible happened')

    subject.add_request(uri: test_uri).with_response do |r|
      expect(r.status).to eq(500)
    end
  end

  context 'exception propagation' do
    before(:each) do
      stub_request(:get, test_uri)
        .to_raise(Faraday::ConnectionFailed)
    end

    it 'propagates exceptions to the calling thread when #join is called' do
      r = subject.add_request(uri: test_uri)
      expect { r.join }.to raise_error(Faraday::ConnectionFailed)
    end

    it 'propagates exceptions when the response is requested' do
      r = subject.add_request(uri: test_uri)
      expect { r.with_response { |_| } }
        .to raise_error(Faraday::ConnectionFailed)
    end
  end
end
