module Krikri
  class ValidationReport
    attr_accessor :provider_id, :page, :rows

    REQUIRED_FIELDS = ['dataProvider_name', 'isShownAt_id', 'preview_id',
                       'sourceResource_rights', 'sourceResource_title',
                       'sourceResource_type_id']

    ##
    # @example
    #   ValidationReport.new.all
    #   => [#<Blacklight::SolrResponse::Facets::FacetField:0x007fce32f46fe8 ...]
    #
    # @example
    #   report = ValidationReport.new
    #   report.provider_id = '0123'
    #   report.all
    #   => [#<Blacklight::SolrResponse::Facets::FacetField:0x007fce32f46fe8 ...]
    #
    # @return [Array<Blacklight::SolrResponse::Facets::FacetField>] a report for
    #   missing values in each of the `REQUIRED_FIELDS`
    def all
      query_params = { :rows => 0,
                       'facet.field' => REQUIRED_FIELDS,
                       'facet.mincount' => 10000000,
                       'facet.missing' => true }
      query_params[:fq] = "provider_id:\"#{provider_uri}\"" if
        provider_id.present?

      Krikri::SolrResponseBuilder.new(query_params).response.facets
    end

    ##
    # @param id [String] a field to check for missing values
    #
    # @example
    #   ValidationReport.new.find('sourceResource_title')
    #   => {"responseHeader"=>{"status"=>0, "QTime"=>123},
    #       "response"=>{"numFound"=>2653, "start"=>0, "docs"=>[...]}}
    #
    # @example
    #   report = ValidationReport.new
    #   report.provider_id = '0123'
    #   report.rows = 100
    #   report.find('sourceResource_title')
    #
    # @raise [RSolr::Error::Http] for non-existant field requests
    # @return [Blacklight::SolrResponse]
    def find(id)
      query_params = { :qt => 'standard', :q => "-#{id}:[* TO *]" }
      query_params[:rows] = @rows.present? ? @rows : '10'
      query_params[:fq] = "provider_id:\"#{provider_uri}\"" if
        provider_id.present?
      query_params[:start] = (@page.to_i * @rows.to_i - 1) if @page.present? &&
                                                              @rows.present?

      Krikri::SolrResponseBuilder.new(query_params).response
    end

    private

    def provider_uri
      return unless provider_id.present?
      Krikri::Provider.new(provider_id).rdf_subject
    end
  end
end
