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
    #
    # @return [RDF::SPARQL::Query] a query object that, when executed, will
    #   give solutions containing the URIs for the resources in `#record`.
    def find_by_activity(activity_uri)
      raise ArgumentError, 'activity_uri must be an RDF::URI' unless
        activity_uri.respond_to? :to_term
      SPARQL_CLIENT.select(:record)
        .where([:record,
                [RDF::PROV.wasGeneratedBy, '|', RDF::DPLA.wasRevisedBy],
                activity_uri.to_term])
    end
  end
end
