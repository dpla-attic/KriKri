module Krikri
  ##
  # Implements SPARQL queries for finding RDF Resources by their PROV-O history.
  module ProvenanceQueryClient
    SPARQL_CLIENT = Repository.query_client

    module_function

    ##
    # Finds all entities generated or revised by the activity whose URI is
    # given.
    #
    # @param activity_uri [#to_uri] the URI of the activity to search
    # @param include_invalidated [Boolean]  Whether to include entities that
    #   have been invalidated with <http://www.w3.org/ns/prov#invalidatedAtTime>
    #
    # @return [RDF::SPARQL::Query] a query object that, when executed, will
    #   give solutions containing the URIs for the resources in `#record`.
    #
    # @see https://www.w3.org/TR/prov-o/#invalidatedAtTime
    # @see Krikri::LDP::Invalidatable
    def find_by_activity(activity_uri, include_invalidated = false)
      raise ArgumentError, 'activity_uri must be an RDF::URI' unless
        activity_uri.respond_to? :to_term
      query = SPARQL_CLIENT.select(:record)
        .where([:record,
                [RDF::PROV.wasGeneratedBy, '|', RDF::DPLA.wasRevisedBy],
                activity_uri.to_term])

      return query if include_invalidated

      # When `include_invalidated` is false, we need to say "and if 
      # RDF::PROV.invalidatedAtTime is not set."
      #
      # The SPARQL query should be:
      #
      # ```
      #   PREFIX prov: <http://www.w3.org/ns/prov#>
      #   SELECT * WHERE {
      #     ?subject prov:wasGeneratedBy  <http://xampl.org/ldp/activity/n> .
      #     FILTER NOT EXISTS { ?subject prov:invalidatedAtTime ?x }
      #   }
      # ```
      query.filter 'NOT EXISTS ' \
                   "{ ?record #{RDF::PROV.invalidatedAtTime.to_base} ?x }"
    end
  end
end
