module Krikri
  ##
  # Implements SPARQL queries for finding RDF Resources by their provider.
  module QAQueryClient
    SPARQL_CLIENT = Repository.query_client

    module_function

    def values_agg_data_provider(provider_uri)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
         provider_uri.respond_to? :to_uri
      SPARQL_CLIENT.select(:s, :value)
        .where([:s, RDF::EDM.provider, provider_uri],
               [:s, RDF::RDFV.type, RDF::ORE.Aggregation])
        .optional([:s, RDF::EDM.dataProvider, :value])
        .order_by("str(?s) ASC")
    end

    def count_agg_data_provider(provider_uri)
      raise ArgumentError, 'provider_uri must be an RDF::URI' unless
         provider_uri.respond_to? :to_uri
      SPARQL_CLIENT.select(:value, count: { '*' => :count })
        .where([:s, RDF::EDM.provider, provider_uri],
               [:s, RDF::RDFV.type, RDF::ORE.Aggregation])
        .optional([:s, RDF::EDM.dataProvider, :value])
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