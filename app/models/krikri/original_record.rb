module Krikri
  ##
  # Handles records as harvested, prior to mapping
  class OriginalRecord
    include Krikri::LDP::Resource
    include Krikri::LDP::Invalidatable

    attr_accessor :content, :local_name, :rdf_subject
    attr_writer :content_type

    ##
    # Instantiate an OriginalRecord object with a #local_name matching the
    # argument.
    #
    # @note calling OriginalRecord.new will instantiate an empty object. Use
    #   .load and .build to populate the object on instantiation.
    #
    # @param identifier [#to_s] a string to be prepended to the base URI
    #   (container) to form a fully qualified name for the rdf source.
    def initialize(identifier)
      raise ArgumentError, "#{identifier} is an invalid local name" if
        identifier.include?('/')
      @local_name = identifier
    end

    class << self
      ##
      # Instantiate and populate an existing OriginalRecord Resource.
      #
      # @param identifier [#to_s] a string representing the #local_name or
      #   fully qualified URI for the resource.  Identifier may have a mime type
      #   extension, ie. '123.xml'.
      # @return [OriginalRecord] the instantiated record.
      # @raise when no matching record is found in the LDP datastore
      def load(identifier)
        identifier = identifier.to_s.split('/').last if
          identifier.start_with? base_uri

        if identifier.include?('.')
          record = new(identifier.split('.').first)
        else
          record = new(identifier)
        end

        raise "No #{self} found with id: #{identifier}" unless record.exists?

        if identifier.include?('.')
          record.rdf_subject = "#{base_uri}/#{identifier}"
        else
          record.rdf_subject = nr_uri_from_headers(record.http_head)
        end

        record.reload
      end

      ##
      # Instantiate and populate an OriginalRecord Resource (new or existing)
      # with the specified content and content type.
      #
      # @param identifier [#to_s] a string representing the #local_name for the
      #   resource.
      # @param content [String, #read] a string or IO object containing the
      #   content to persist to the LDP NRSource.
      # @param content_type [String] a valid MIME type for the data contained
      #   in #content.
      # @return [OriginalRecord] the instantiated record.
      #
      # @raise when no matching record is found in the LDP datastore
      # @note Marmotta interprets some content types universally as
      #   LDP-RDFSources. Take care when passing new content types through to
      #   Marmotta; you may get unexpected errors from the server.
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
      # @return [String] the URI namespace/LDP container for resources of this 
      #   class
      def base_uri
        Krikri::Settings['marmotta']['record_container']
      end

      ##
      # @param localname [#to_s] the unique portion of the URI to build; this 
      #   will be combined with `.base_uri` to form the returned URI
      # @return [RDF::URI] a URI built from the `.base_uri` and the `local_name` 
      #   parameter
      #
      # @note we use `RDF::URI.intern` (rather than `.new`) to avoid allocating
      #   memory for a new object for the LDP base URI, taking advantage of 
      #   `RDF::URI.cache`.
      def build_uri(local_name)
        RDF::URI.intern(base_uri) / local_name
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
      true
    end

    def to_s
      content
    end

    def content_type
      @content_type || 'text/xml'
    end

    ##
    # @return [RDF::URI] the URI for the managing RDFSource created for
    #   the record
    # @see http://www.w3.org/TR/ldp/#ldpc-post-createbinlinkmetahdr
    def rdf_source
      @rdf_source ||=
        OriginalRecordMetadata.new(self.class.build_uri(local_name))
    end

    ##
    # Saves over LDP, passing #content and #headers to the request.
    #
    # @param activity_uri  the activity responsible for generation
    # @param update_etag  forces an http_head request to update of the etag
    # @raise (see Krikri::LDP::Resource#save)
    # @return [Boolean] true for success; else false
    #
    # @see Krikri::LDP::Resource#save
    def save(activity_uri = nil, update_etag = false)
      response = super(@content, headers)
      @rdf_subject ||= response.env.response_headers['location']
      http_head(true) if update_etag
      return response unless activity_uri
      rdf_source.wasGeneratedBy = activity_uri
      rdf_source.save
      response
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
      @rdf_subject ||= rdf_source.rdf_subject
      super
    ensure
      @rdf_subject = nil if rdf_subject == rdf_source.rdf_subject
    end

    ##
    # @return [Hash<String, String>]  request headers appropriate for PUT
    #   requests.
    def headers
      { 'Content-Type' => content_type }
    end
  end
end
