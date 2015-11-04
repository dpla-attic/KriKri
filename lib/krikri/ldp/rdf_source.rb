module Krikri::LDP
  ##
  # Adds simple LDP persistence to ActiveTriples::Resource classes
  # @see ActiveTriples::Resource
  #
  # @see http://www.w3.org/TR/ldp/#ldprs
  module RdfSource
    extend ActiveSupport::Concern
    include Krikri::LDP::Resource

    ##
    # PUTs the LDP resource named in #rdf_subject, populating it's content
    # (graph) from the object's RDF::Graph.
    #
    # @see Krikri::LDP::Resource#save
    # @note this may leave the resource's graph out of sync with the LDP 
    #   endpoint since the endpoint may add management triples when saving.
    def save(*)
      result = super(dump(:ttl))
      result
    end

    ##
    # Saves and forces reload. This updates the graph with any management 
    # triples added by the LDP endpoint.
    #
    # @see #save
    def save_and_reload(*args)
      result = save(*args)
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

    ##
    # Adds an appropritate provenance statement with the given URI and saves
    # the resource.
    #
    # This method treats RDFSources as stateful resources. This is in conflict
    # with the PROV model, which assumes each revision is its own Resource. The
    # internal predicate `dpla:wasRevisedBy` is used for non-generating
    # revisions of stateful RDFSources.
    #
    # @todo Assuming a Marmotta LDP server, there are version URIs available
    #   (via Memento) which could be used for a direct PROV implementation.
    #   Consider options for doing that either alongside or in place of this
    #   approach.
    #
    # @param activity_uri [#to_term] the URI of the prov:Activity to mark as
    #   generating or revising the saved resource.
    #
    # @see #save
    #
    # @see http://www.w3.org/TR/prov-primer/
    # @see http://www.w3.org/TR/2013/REC-prov-o-20130430/
    def save_with_provenance(activity_uri)
      predicate =
        exists? ? RDF::DPLA.wasRevisedBy : RDF::PROV.wasGeneratedBy
      self << RDF::Statement(self, predicate, activity_uri)
      save
    end

    private

    ##
    # Clears the RDF::Graph and repopulates it from the http body. Forces text
    # encoding to UTF-8 before passing to the `RDF::Reader`.
    # 
    # @return [void]
    #
    # @see http://www.w3.org/TR/turtle/#sec-mime for info about Turtle encoding
    # @see http://www.w3.org/TR/ldp/#h-ldprs-get-turtle for info about LDP GET
    #   and Turtle.
    def reload_ldp
      return reload unless !node? && exists?
      clear
      self << RDF::Reader.for(:ttl).new(@http_cache.body.force_encoding('UTF-8'))
    end
  end
end
