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
    # @param activity [#to_term] the URI of the activity to search
    # @param include_invalidated [Boolean]  Whether to include entities that
    #   have been invalidated with <http://www.w3.org/ns/prov#invalidatedAtTime>
    #
    # @return [SPARQL::Client::Query] a query object that, when executed, will
    #   give solutions containing the URIs for the resources in `#record`.
    #
    # @example 
    #   query = Krikri::ProvenanceQueryClient.find_by_activity(activity_uri)
    #   uris = query.solutions.map(&:record)
    #
    # @see SPARQL::Client::Query for details on how to use a query
    #
    # @see https://www.w3.org/TR/prov-o/#invalidatedAtTime
    # @see Krikri::LDP::Invalidatable
    def find_by_activity(activity, include_invalidated = false)
      validate_activity!(activity)
      query = SPARQL_CLIENT.select(:record).where(pattern_for(activity))

      include_invalidated ? query : add_invalidated_filter(query)
    end

    ##
    # @param activity [#to_term] the URI of the activity to search
    # @param include_invalidated [Boolean]  Whether to include entities that
    #   have been invalidated with <http://www.w3.org/ns/prov#invalidatedAtTime>
    #
    # @return [Integer] the count of distinct matches
    def count_by_activity(activity, include_invalidated = false)
      validate_activity!(activity)
      query = SPARQL_CLIENT.select(:ct, count: { record: :ct })
              .where(pattern_for(activity))

      query = include_invalidated ? query : add_invalidated_filter(query)
      query.solutions.first[:ct].object
    end

    ##
    # Adds a filter, removing results with a `prov:invalidedAtTime`.
    #
    # @param query [SPARQL::Client::Query]
    # @return [SPARQL::Client::Query] the original query with an added filter
    #
    # We need to say "and if RDF::PROV.invalidatedAtTime is not set."
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
    # 
    # @note this assumes that the query originated from this module's query 
    #   generators
    def add_invalidated_filter(query)
      query.filter 'NOT EXISTS ' \
                   "{ ?record #{RDF::PROV.invalidatedAtTime.to_base} ?x }"
    end

    private

    ##
    # @param activity_uri [Object]
    # @return [void]
    # @raise [ArgumentError] unless `activity_uri` is an `RDF::Term`
    def self.validate_activity!(activity_uri)
      raise ArgumentError, 'activity_uri must be an RDF::URI' unless
        activity_uri.respond_to? :to_term
    end

    ##
    # @param activity [#to_term]
    # @return [Array] an array representing an RDF::Query::Pattern for the 
    #   given activity
    def self.pattern_for(activity)
      [:record, 
       [RDF::PROV.wasGeneratedBy, '|', RDF::DPLA.wasRevisedBy], 
       activity.to_term]
    end
  end
end
