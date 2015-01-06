module Krikri
  ##
  # Handles records as harvested, prior to mapping
  class OriginalRecord
    include Krikri::LDP::Resource

    attr_accessor :content, :local_name, :rdf_subject
    attr_writer :content_type

    def initialize(identifier)
      @local_name = identifier
    end

    class << self
      def load(identifier)
        record = new(identifier)
        raise "No #{self} found with id: identifier" unless record.exists?
        record.rdf_subject = nr_uri_from_headers(record.http_head)
        record.reload
      end

      def build(identifier, content, content_type = nil)
        raise(ArgumentError,
              '`content` must be a readable IO object or String.'\
              "Got a #{content.class}") unless
          content.is_a?(String) || content.respond_to?(:read)
        record = new(identifier)
        record.reload if record.exists?
        record.content = content
        record.content_type = content_type
        record
      end

      ##
      # Gets the URI for the ldp:NonRDFSource from the Headers returned by the
      # containing ldp:RDFSource.
      #
      # @see http://www.w3.org/TR/ldp/#ldpc-post-createbinlinkmetahdr
      # @todo figure out how to handle situations where more than one NR is
      #   described by the same RDFSource (second file PUT to same URI)
      def nr_uri_from_headers(headers)
        links = headers['link'].split(',').select! do |link|
          link.include? 'rel="content"'
        end

        links.first[/.*<(.*)>/, 1]
      end
    end

    def ==(other)
      return false unless other.is_a? OriginalRecord
      return false unless local_name == other.local_name
      return false unless content == other.content
      return false unless content_type == other.content_type
      return false unless etag == other.etag
      true
    end

    def to_s
      content
    end

    def content_type
      @content_type || 'application/octet-stream'
    end

    ##
    # @return [RDF::URI] the URI for the managing RDFSource created for
    #   the record
    # @see http://www.w3.org/TR/ldp/#ldpc-post-createbinlinkmetahdr
    def rdf_source
      RDF::URI(File.join(Krikri::Settings['marmotta']['record_container'],
                         local_name))
    end

    ##
    # Saves over LDP, passing #content and #headers to the request.
    #
    # @raise (see Krikri::LDP::Resource#save)
    # @return [Boolean] true for success; else false
    #
    # @see Krikri::LDP::Resource#save
    def save
      response = super(@content, headers)
      @rdf_subject ||= response.env.response_headers['location']
      http_head(true)
      exists?
    end

    ##
    # Reloads the record from its LDP URI, updates #content to the response body
    #
    # @raise (see Krikri::LDP::Resource#get)
    # @return [OriginalRecord] self
    def reload
      @rdf_subject ||= self.class.nr_uri_from_headers(http_head)
      response = get(nil, true)
      self.content_type = response.env.response_headers['content-type']
      self.content = response.env.body
      self
    end

    private

    ##
    # Marmotta creates a new ldp:RDFSource at the requested URL and adds
    # requested NRs with an appropriate file extension. This overrides requests
    # to use the rdf_source until the resource exists, and the appropriate
    # LDP-NR URI thereafter.
    #
    # @raise (see Krikri::LDP::Resource#make_request)
    # @return (see Krikri::LDP::Resource#make_request)
    # @see Krikri::LDP::Resource#make_request
    # @todo this might not be thread safe! Initializer checks existance of
    #   rdf_source and sets rdf_subject appropriately, but race conditions
    #   are possible.
    def make_request(method, body = nil, headers = {})
      @rdf_subject ||= rdf_source
      super
    ensure
      @rdf_subject = nil if rdf_subject == rdf_source
    end

    ##
    # @return [Hash<String, String>]  request headers appropriate for PUT
    #   requests.
    def headers
      { 'Content-Type' => content_type }
    end
  end
end
