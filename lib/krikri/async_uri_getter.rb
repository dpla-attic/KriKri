require 'faraday'
require 'faraday_middleware'

require 'net/http'
require 'thread'
require 'uri'

module Krikri
  ##
  # Helper class for fetching multiple URLs concurrently. 
  #
  # @example to fetch 5 URLs in 5 threads
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
  #      getter.add_request(uri: url, opts: { follow_redirects: true })
  #    end
  #    
  # At this point, 5 threads are launched to fetch the list of URLs.  We can
  # wait for them all to finish if we want to make sure we don't continue until
  # all threads have terminated: `requests.map(&:join)`
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
    # @option opts [Boolean] :follow_redirects  Whether to follow HTTP 3xx
    #   redirects.
    # @option opts [Integer] :max_redirects Number of redirects to follow before
    #   giving up. (default: 10)
    # @option opts [Boolean] :inline_exceptions If true, pass exceptions as a
    #   5xx response with the exception string in the body. (default: false)
    def initialize(opts: {})
      @default_opts = { max_redirects: MAX_REDIRECTS }.merge(opts)
    end

    ##
    # Run a request (in a new thread) and return a promise-like object for the
    # response.
    #
    # @param uri [URI] the URI to be fetched
    # @param headers [Hash<String, String>] HTTP headers to include with the
    #   request
    # @param opts [Hash] options to override the ones provided when
    #   AsyncUriGetter was initialized. All supported options from `#initialize`
    #   are available here as well.
    def add_request(uri: nil, headers: {}, opts: {})
      fail ArgumentError, "uri must be a URI; got: #{uri}" unless uri.is_a?(URI)
      Request.new(uri, headers, @default_opts.merge(opts))
    end

    Request = Struct.new(:uri, :headers, :opts) do
      def initialize(*)
        super
        @request_thread = start_request
      end

      ##
      # Wait for the request thread to complete
      def join
        @request_thread.join
      rescue => e
        # If the join throws an exception, the thread is dead anyway.  The
        # subsequent call to `with_response` will propagate the exception to the
        # calling thread.
        raise e unless inline_exceptions?
      end

      ##
      # @yield [Faraday::Response] the response returned for the request
      def with_response
        yield @request_thread.value
      rescue => e
        if inline_exceptions?
          # Deliver an error response to the caller to allow uniform access
          msg = e.message + "\n\n" + e.backtrace.join("\n")
          yield Faraday::Response.new(status: 500,
                                      body: msg,
                                      response_headers: {
                                        'X-Exception' => e,
                                        'X-Exception-Message' => e.message,
                                        'X-Internal-Response' => 'true'
                                      })
        else
          raise e
        end
      end

      private

      ##
      # True if we are using inline exceptions
      def inline_exceptions?
        opts.fetch(:inline_exceptions, false)
      end

      ##
      # Run the Faraday request in a new thread
      def start_request
        Thread.new do
          http.get(uri) do |request|
            headers.each { |header, val| request.headers[header.to_s] = val }
          end
        end
      end

      ##
      # @return [Faraday::Connection] a connection with sensible defaults
      def http
        @http ||= Faraday.new do |conn|
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
