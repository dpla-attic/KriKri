module Krikri
  ##
  # Implements SPARQL queries for finding values and counts of values in
  # RDF Resources by edm:provider.
  module QAQueryClient
    SPARQL_CLIENT = Repository.query_client
    TYPE = :aggregation
    VALUE = :value

    module_function

    ##
    # Writes a {SPARQL::Client::Query} against the Repository for values
    # matching at the end of a chain of predicates.
    #
    # @example
    #   QAQueryClient.values_for_predicate(RDF::EDM.hasView,
    #     RDF::URI('http://example.org/moomin'))
    #   => #<SPARQL::Client::Query:0x3fb814e241e8(
    #        SELECT ?aggregation ?value ?isShownAt WHERE {
    #          ?aggregation <http://www.europeana.eu/schemas/edm/provider>
    #            <http://example.org/moomin> .
    #          ?aggregation a
    #            <http://www.openarchives.org/ore/terms/Aggregation> .
    #          OPTIONAL {
    #            ?aggregation <http://www.europeana.eu/schemas/edm/hasView>
    #              ?value .
    #            ?aggregation <http://www.europeana.eu/schemas/edm/isShownAt>
    #              ?isShownAt .
    #          }
    #        } ORDER BY ?aggregation)>
    #
    # @example
    #   QAQueryClient.values_for_predicate([RDF::EDM.aggregatedCHO,
    #                                       RDF::DC.title],
    #     RDF::URI('http://example.org/moomin').execute.first.value
    #   => #<SPARQL::Client::Query:0x3fb814e8379c(
    #        SELECT ?aggregation ?value ?isShownAt WHERE {
    #          ?aggregation <http://www.europeana.eu/schemas/edm/provider>
    #            <http://example.org/moomin> .
    #          ?aggregation a
    #            <http://www.openarchives.org/ore/terms/Aggregation> .
    #          OPTIONAL {
    #            ?aggregation
    #              <http://www.europeana.eu/schemas/edm/aggregatedCHO> ?obj0 .
    #            ?obj0 <http://purl.org/dc/terms/title> ?value .
    #            ?aggregation <http://www.europeana.eu/schemas/edm/isShownAt>
    #              ?isShownAt .
    #          }
    #        } ORDER BY ?aggregation)>
    #
    # @example
    #   QAQueryClient.values_for_predicate([RDF::EDM.aggregatedCHO,
    #                                       RDF::DC.title],
    #     RDF::URI('http://example.org/moomin').execute.first.value
    #   # => "Stonewall Inn [2]"
    #
    # @param predicates [#to_uri, Array<#to_uri>] a predicate or list of
    #   predicates to query
    # @param provider_uri [#to_uri] a URI for an edm:provider value. Results
    #   will be filtered to Resources that have this provider.
    #
    # @return [SPARQL::Client::Query] a query object that will give solutions
    #   with `:value`, `:aggregation`, and `:isShownAt` variables.
    def values_for_predicate(predicates, provider_uri = nil)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
        provider_uri.respond_to? :to_uri

      optional_patterns = build_optional_patterns(predicates)

      optional_patterns << [TYPE, RDF::EDM.isShownAt, :isShownAt]

      SPARQL_CLIENT.select(TYPE, VALUE, :isShownAt)
        .where(*where_patterns(provider_uri))
        .optional(*optional_patterns)
        .order_by(TYPE)
    end

    ##
    # Writes a {SPARQL::Client::Query} against the Repository for counts of
    # values matching at the end of a chain of predicates.
    #
    # @example
    #   QAQueryClient.counts_for_predicate(RDF::EDM.hasView,
    #     RDF::URI('http://example.org/moomin')
    #   => #<SPARQL::Client::Query:0x3fa596c6f068(
    #        SELECT ?value ( COUNT(*) AS ?count ) WHERE {
    #          ?aggregation <http://www.europeana.eu/schemas/edm/provider>
    #            <http://example.org/moomin> .
    #          ?aggregation a
    #            <http://www.openarchives.org/ore/terms/Aggregation> .
    #          OPTIONAL {
    #            ?aggregation <http://www.europeana.eu/schemas/edm/hasView>
    #              ?value .
    #          }
    #        } GROUP BY ?value ORDER BY DESC(?count))>
    #
    # @param predicates [#to_uri, Array<#to_uri>] a predicate or list of
    #   predicates to query
    # @param provider_uri [#to_uri] a URI for an edm:provider value. Results
    #   will be filtered to Resources that have this provider.
    #
    # @return [SPARQL::Client::Query] a query object that will give solutions
    #   with `:value` and `:count` variables.
    def counts_for_predicate(predicates, provider_uri = nil)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
        provider_uri.respond_to? :to_uri

      optional_patterns = build_optional_patterns(predicates)

      SPARQL_CLIENT.select(VALUE, count: { '*' => :count })
        .where(*where_patterns(provider_uri))
        .optional(*optional_patterns)
        .group_by(VALUE)
        .order_by('DESC(?count)')
    end

    ##
    # @param provider_uri [#to_uri] a URI for an edm:provider value.
    #
    # @return [Array<Array<#to_term>>] An array of pattern arrays that match
    #   ore:Aggregations with the given provider_uri
    # @see RDF::Query
    # @see RDF::Query::Pattern
    def where_patterns(provider_uri)
      [[TYPE, RDF::EDM.provider, provider_uri],
       [TYPE, RDF.type, RDF::ORE.Aggregation]]
    end

    ##
    # Builds patterns matching a predicate or chain of predicates given,
    # assigning an unbound variable to each set of matches and passing it to
    # the next pattern.
    #
    # @param predicates [#to_uri, Array<#to_uri>] a predicate or list of
    #   predicates to build patterns against.
    #
    # @return [Array<Array<#to_term>>] An array of pattern arrays
    # @see RDF::Query
    # @see RDF::Query::Pattern
    def build_optional_patterns(predicates)
      return [[TYPE, predicates, VALUE]] unless
        predicates.is_a? Enumerable

      var1 = TYPE
      patterns = predicates.each_with_object([]) do |predicate, ps|
        var2 =
          (ps.count == predicates.size - 1) ? VALUE : "obj#{ps.count}".to_sym
        ps << [var1, predicate, var2]
        var1 = var2
      end
    end
  end
end
