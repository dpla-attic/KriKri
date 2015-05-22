require 'faraday'
require 'faraday_middleware'

module Krikri::LDP
  ##
  # Implements basic LDP CRUD operations
  module Resource
    extend ActiveSupport::Concern

    ##
    # @return [Faraday::Connection] a connection to the configured LDP endpoint
    def ldp_connection
      @ldp_conn ||= Faraday.new(ldp_ns) do |conn|
        conn.request :retry, max: 4, interval: 0.025,
                     interval_randomness: 0.5, backoff_factor: 2,
                     exceptions: [Faraday::ConnectionFailed,
                                  'Errno::ETIMEDOUT',
                                  'Timeout::Error',
                                  'Error::TimeoutError',
                                  Faraday::TimeoutError]
        conn.use Faraday::Response::RaiseError
        conn.use FaradayMiddleware::FollowRedirects, limit: 3
        conn.adapter Faraday.default_adapter
      end
    end

    ##
    # Returns the current etag if the resource exists. If no etag is cached,
    # this will trigger an HTTP HEAD request to retrieve the current one from
    # the server.
    #
    # @return [String] the current cached HTTP ETag for the resource
    def etag
      http_head['etag'] if exists?
    end

    ##
    # Returns the current last-modified header if the resource exists. If none
    # is cached, this will trigger an HTTP HEAD request to retrieve the current
    # one from the server.
    #
    # @return [String] the current cached Last-Modified date for the resource
    def modified_date
      http_head['last-modified'] if exists?
    end

    ##
    # Sends a HEAD request to #rdf_subject and caches the headers. Executes
    # lazily unless `force` parameter is `true`, using cached values if present.
    #
    # @param force [Boolean] force request if true
    #
    # @raise (see #make_request)
    # @return [Hash<String, String>] a hash of HTTP headers
    def http_head(force = false)
      return @http_headers if @http_headers && !force
      @http_headers = make_request(:head).env['response_headers']
    end

    ##
    # Sends a GET request to #rdf_subject and caches the headers and body.
    # Executes lazily unless `force` parameter is `true`, using cached values
    # if present.
    #
    # @param headers [Hash<String, String>] a hash of HTTP headers;
    #   e.g. {'Content-Type' => 'text/plain'}.
    # @param force [Boolean] force request if true
    #
    # @raise (see #make_request)
    # @return [Faraday::Response] the server's response
    def get(headers = {}, force = false)
      return @http_cache if @http_cache && !force
      response = make_request(:get, nil, headers)
      @http_headers = response.env['response_headers']
      @http_cache = response
    end

    ##
    # @return [Boolean] true if the LDP server already knows about the resource;
    #   false if the resource is not found (404) or is deleted (HTTP 410).
    #
    # @see Faraday::ResourceNotFound, Faraday::ClientError#status
    # @see #http_head
    def exists?
      return true if http_head
      false
    rescue Faraday::ResourceNotFound
      false
    rescue Faraday::ClientError => e
      return false if !e.response.nil? && e.response[:status] == 410
      raise e
    end
    alias_method :exist?, :exists?

    ##
    # Sends PUT request to the resource's #rdf_subject via #ldp_connection.
    # A body and headers can be passed in. Default HTTP headers are:
    #
    #    Content-Type: 'text/turtle' (i.e. creates an LDP-RS)
    #    If-Match: "#{etag}" (uses idempotent put if an Entity Tag is cached)
    #
    # @param body [#to_s] the request body.
    # @param headers [Hash<String, String>] a hash of HTTP headers;
    #   e.g. {'Content-Type' => 'text/plain'}.
    #
    # @raise (see #make_request)
    # @return [Faraday::Response] the server's response
    def save(body = nil, headers = {})
      headers['Content-Type'] ||= default_content_type
      headers['If-Match'] ||= etag if exists?
      response = make_request(:put, body, headers)
      @http_headers = response.env['response_headers']
      response
    end

    ##
    # Sends DELETE request to the resource's #rdf_subject via #ldp_connection.
    # Headers can be passed in. Default HTTP headers are:
    #
    #    If-Match: "#{etag}" (uses idempotent put if an Entity Tag is cached)
    #
    def delete!(headers = {})
      raise "Cannot delete #{rdf_subject}, does not exist." unless exist?
      headers['If-Match'] ||= etag
      response = make_request(:delete, nil, headers)
      @http_headers = nil
      response
    end

    private

    ##
    # Lightly wraps Faraday to manage requests of various types, their bodies
    # and headers.
    #
    # @param method [Symbol] HTTP method/verb.
    # @param body [#to_s] the request body.
    # @param headers [Hash<String, String>] a hash of HTTP headers;
    #   e.g. {'Content-Type' => 'text/plain'}.
    #
    # @raise [Faraday::ClientError] if the server responds with an error status.
    #   Faraday::ClientError#response contains the full response.
    # @return [Faraday::Response] the server's response
    def make_request(method, body = nil, headers = {})
      validate_subject
      ldp_connection.send(method) do |request|
        request.url rdf_subject
        request.headers = headers if headers
        request.body = body
      end
    end

    def default_content_type
      'text/turtle'
    end

    private

    def ldp_ns
      Krikri::Settings['marmotta']['ldp']
    end

    def validate_subject
      validate_not_nil
      validate_not_node
      validate_namespace
      true
    end

    def validate_not_nil
      raise "#{self.class} requires a URI rdf_subject, but got nil." if
        rdf_subject.nil?
    end

    def validate_not_node
      raise "#{self.class} requires a URI rdf_subject, but got a node." if
        rdf_subject.respond_to?(:node?) && rdf_subject.node?
    end

    def validate_namespace
      raise "#{self.class} requires an rdf_subject in #{ldp_ns}, but "\
      "got #{rdf_subject}." unless rdf_subject.to_s.starts_with? ldp_ns
    end
  end
end
