module Krikri
  # Constructs a list of Validation Reports
  class ValidationReportList
    include Krikri::QaProviderFilter

    REQUIRED_FIELDS = ['dataProvider_name', 'isShownAt_id', 'preview_id',
                       'sourceResource_rights', 'sourceResource_title',
                       'sourceResource_type_id']

    def initialize
      @index_querier = Krikri::IndexQuerier.new
      @default_query_params = { :rows => 0,
                                'facet.field' => REQUIRED_FIELDS,
                                'facet.mincount' => 10000000,
                                'facet.missing' => true }
    end

    # @return Hash
    def report_list
      list_for_display(report_list_facets(@default_query_params))
    end

    ##
    # @param String
    # @return Hash
    def report_list_by_provider(provider)
      query_params = @default_query_params.merge(:fq => provider_fq(provider))
      list_for_display(report_list_facets(query_params))
    end

    private

    ##
    # @param Hash
    # @return Array of Blacklight::SolrResponse::Facets::FacetField's
    def report_list_facets(query_params)
      @index_querier.search(query_params).facets
    end

    ##
    # @param Array of Blacklight::SolrResponse::Facets::FacetField's
    # @return Array of Hashes. Hash will be in the format:
    #   [{ :label => "field_name (2)", :link_url => "validation_reports?[...]"}]
    def list_for_display(reports)
      reports.map do |report|
        report_link(report.name, report.items.first.hits)
      end
    end

    ##
    # Construct a link and display label for a validation report
    # The param 'report_name' in the constructed link is not used by Solr
    #  - it is for display purposes only
    # @param: String, Integer
    # @return: Hash
    def report_link(name, count)
      link = { :label => "#{name} (#{count})" }
      return link unless count > 0
      link[:url] = "validation_reports?q=-#{name}:[*%20TO%20*]" \
                    "&report_name=#{name}"
      link
    end
  end
end
