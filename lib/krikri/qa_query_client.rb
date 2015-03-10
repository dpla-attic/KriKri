module Krikri
  ##
  # Implements SPARQL queries for finding RDF Resources by their provider.
  module QAQueryClient
    SPARQL_CLIENT = Repository.query_client

    module_function

    # need methods to handle more complex situations:
    # * things with prefLabel or providedLabel
    # * dates - this should probably be its own
    def values_for_simple_aggregation_predicate(provider_uri, predicate)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
         provider_uri.respond_to? :to_uri
      SPARQL_CLIENT.select(:s, :value)
        .where([:s, RDF::EDM.provider, provider_uri],
               [:s, RDF::RDFV.type, RDF::ORE.Aggregation])
        .optional([:s, predicate, :value])
        .order_by("str(?s) ASC")
    end

    def values_for_simple_sourceresource_predicate(provider_uri, predicate)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
         provider_uri.respond_to? :to_uri
      SPARQL_CLIENT.select(:s, :value)
        .where([:s, RDF::EDM.provider, provider_uri],
               [:s, RDF::RDFV.type, RDF::ORE.Aggregation])
        .optional([:s, RDF::EDM.aggregatedCHO, :sr],
                  [:sr, predicate, :value])
        .order_by("str(?s) ASC")
    end

    def count_for_aggregation_predicate(provider_uri, predicate)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
         provider_uri.respond_to? :to_uri
      SPARQL_CLIENT.select(:value, count: { '*' => :count })
        .where([:s, RDF::EDM.provider, provider_uri],
               [:s, RDF::RDFV.type, RDF::ORE.Aggregation])
        .optional([:s, predicate, :value])
        .group_by(:value)
        .order_by("?count DESC")
    end

    def count_for_simple_sourceresource_predicate(provider_uri, predicate)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
         provider_uri.respond_to? :to_uri
      SPARQL_CLIENT.select(:value, count: {'*' => :count} )
        .where([:s, RDF::EDM.provider, provider_uri],
               [:s, RDF::RDFV.type, RDF::ORE.Aggregation])
        .optional([:s, RDF::EDM.aggregatedCHO, :sr],
                  [:sr, predicate, :value])
        .group_by(:value)
        .order_by("?count DESC")
    end

    def values_agg_data_provider(provider_uri)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
         provider_uri.respond_to? :to_uri
      SPARQL_CLIENT.select(:s, :value)
        .where([:s, RDF::EDM.provider, provider_uri],
               [:s, RDF::RDFV.type, RDF::ORE.Aggregation])
        .optional([:s, RDF::EDM.dataProvider, :dp],
                  [:dp, RDF::DPLA.providedLabel, :value])
        .order_by("str(?s) ASC")
    end

    def count_agg_data_provider(provider_uri)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
         provider_uri.respond_to? :to_uri
      SPARQL_CLIENT.select(:value, count: { '*' => :count })
        .where([:s, RDF::EDM.provider, provider_uri],
               [:s, RDF::RDFV.type, RDF::ORE.Aggregation])
        .optional([:s, RDF::EDM.dataProvider, :dp],
                  [:dp, RDF::DPLA.providedLabel, :value])
        .group_by(:value)
        .order_by("?count DESC")
    end

    def values_sr_title(provider_uri)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
         provider_uri.respond_to? :to_uri
      SPARQL_CLIENT.select(:s, :value)
        .where([:s, RDF::EDM.provider, provider_uri],
               [:s, RDF::RDFV.type, RDF::ORE.Aggregation])
        .optional([:s, RDF::EDM.aggregatedCHO, :sr],
                  [:sr, RDF::DC.title, :value])
        .order_by("str(?s) ASC")
    end

    def count_sr_title(provider_uri)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
         provider_uri.respond_to? :to_uri
      SPARQL_CLIENT.select(:value, count: {'*' => :count} )
        .where([:s, RDF::EDM.provider, provider_uri],
               [:s, RDF::RDFV.type, RDF::ORE.Aggregation])
        .optional([:s, RDF::EDM.aggregatedCHO, :sr],
                  [:sr, RDF::DC.title, :value])
        .group_by(:value)
        .order_by("?count DESC")
    end
  end
end