require 'faraday'
require 'faraday_middleware'

require 'net/http'
require 'thread'
require 'uri'

module Krikri
  ##
  # Helper class for fetching multiple URLs concurrently. For example, to fetch
  # 5 URLs in 5 threads:
  #
  #    urls = ['http://example.com/one',
  #            'http://example.com/two',
  #            'http://example.com/three',
  #            'http://example.com/four',
  #            'http://example.com/five']
  #           .map { |url| URI.parse(url) }
  #
  #    getter = Krikri::AsyncUriGetter.new
  #
  #    requests = urls.map do |url|
  #      getter.add_request(uri: url,
  #                         opts: {
  #                           follow_redirects: true
  #                         })
  #    end
  #
  # At this point, 5 threads are launched to fetch the list of URLs.  We can
  # wait for them all to finish if we want to make sure we don't continue until
  # all threads have terminated:
  #
  #    requests.map(&:join)
  #
  # Or simply access the responses and have our current thread block until
  # they're available:
  #
  #    requests.each do |request|
  #      request.with_response do |response|
  #        if response.status == 200
  #          puts "Response body: #{response.body}"
  #        else
  #          puts "Got return status: #{response.status}"
  #        end
  #      end
  #    end
  #
  class AsyncUriGetter
    MAX_REDIRECTS = 10

    ##
    # Create a new asynchronous URL fetcher.
    #
    # @param opts [Hash] a hash of the supported options, which are:
    #
    #  - follow_redirects: (true or false) -- whether to follow HTTP 3xx
    #      redirects.
    #
    #  - max_redirects: [N] (default: 10) -- how many redirects to follow before
    #      giving up
    #
    def initialize(opts: {})
      @default_opts = { max_redirects: MAX_REDIRECTS }.merge(opts)
    end

    ##
    # Run a request (in a new thread) and return a promise-like object for the
    # response.
    #
    # @param uri [URI] the URI to be fetched
    #
    # @param headers [Hash<String, String>] HTTP headers to include with the
    #   request
    #
    # @param opts [Hash] options to override the ones provided when
    #   AsyncUriGetter was initialized. All supported options are available here
    #   as well.
    #
    def add_request(uri: nil, headers: {}, opts: {})
      fail ArgumentError, 'uri must be a URI' unless uri.is_a?(URI)
      Request.new(uri, headers, @default_opts.merge(opts))
    end

    Request = Struct.new(:uri, :headers, :opts) do
      def initialize(*)
        super
        @request_thread = start_request
      end

      ##
      # Wait for the request thread to complete
      #
      def join
        @request_thread.join
      end

      ##
      # @yield [Faraday::Response] the response returned for the request
      #
      def with_response
        yield(@request_thread.value)
      end

      private

      ##
      # Run the Faraday request in a new thread
      #
      def start_request
        Thread.new do
          http.get(uri) do |request|
            headers.each do |header, value|
              request.headers[header.to_s] = value
            end
          end
        end
      end

      ##
      # @return [Faraday::Connection] a connection with sensible defaults
      #
      def http
        Faraday.new do |conn|
          conn.request :retry,
                       max: 4,
                       interval: 0.025,
                       interval_randomness: 0.5,
                       backoff_factor: 2,
                       exceptions: [Faraday::ConnectionFailed,
                                    'Errno::ETIMEDOUT',
                                    'Timeout::Error',
                                    'Error::TimeoutError',
                                    Faraday::TimeoutError]
          if opts.fetch(:follow_redirects, false)
            conn.use(FaradayMiddleware::FollowRedirects,
                     limit: opts.fetch(:max_redirects))
          end

          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end
