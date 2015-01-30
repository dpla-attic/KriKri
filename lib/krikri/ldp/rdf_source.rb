module Krikri::LDP
  ##
  # Adds simple LDP persistence to ActiveTriples::Resource classes
  # @see ActiveTriples::Resource
  module RdfSource
    extend ActiveSupport::Concern
    include Krikri::LDP::Resource

    ##
    # PUTs the LDP resource named in #rdf_subject, populating it's content
    # (graph) from the object's RDF::Graph.
    #
    # @see Krikri::LDP::Resource#save
    # @note this forces a (GET/#get) reload of the resource after save
    #   since the LDP endpoint may add management triples in the response.
    def save(*)
      result = super(dump(:ttl))
      get({}, true)
      result
    end

    ##
    # GETs the LDP resource from #rdf_subject and resets this object's
    # RDF::Graph to match the one returned from the LDP server.
    #
    # @see Krikri::LDP::Resource#get
    def get(*args)
      result = super
      reload_ldp
      result
    end

    private

    ##
    # Clears the RDF::Graph and repopulates it from the http body.
    def reload_ldp
      return reload unless !node? && exists?
      clear
      self << RDF::Reader.for(:ttl).new(@http_cache.body).statements
    end
  end
end
