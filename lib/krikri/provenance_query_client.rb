module Krikri
  ##
  # Implements SPARQL queries for finding RDF Resources by their PROV-O history.
  module ProvenanceQueryClient
    SPARQL_CLIENT = Repository.query_client

    module_function

    def find_by_activity(activity_uri)
      raise ArgumentError, 'activity_uri must be an RDF::URI' unless
        activity_uri.respond_to? :to_uri
      SPARQL_CLIENT.select(:record)
        .where([:record, RDF::PROV.wasGeneratedBy, activity_uri])
    end
  end
end
