module Krikri
  class ValidationReport
    attr_accessor :provider_id, :start, :rows

    REQUIRED_FIELDS = ['dataProvider_name', 'isShownAt_id', 'preview_id',
                       'sourceResource_rights', 'sourceResource_title',
                       'sourceResource_type_id']

    ##
    # @param &block may contain provider_id
    #   Sample use:
    #     ValidationReport.new.all do
    #       self.provider_id = '0123'
    #     end
    #
    # @return [Array<Blacklight::SolrResponse::Facet>]
    def all(&block)
      # set values from block
      instance_eval &block if block_given?

      query_params = { :rows => 0,
                       'facet.field' => REQUIRED_FIELDS,
                       'facet.mincount' => 10000000,
                       'facet.missing' => true }
      query_params[:fq] = "provider_id:\"#{provider_uri}\"" if
        provider_id.present?

      Krikri::SolrResponseBuilder.new(query_params).response.facets
    end

    ##
    # @param id [String]
    # @param &block may contain provider_id, start, rows
    #   Sample use:
    #     ValidationReport.new.find('sourceResource_title') do
    #       self.provider_id = '0123'
    #     end
    #
    # @raise [RSolr::Error::Http] for non-existant field requests
    # @return [Blacklight::SolrResponse]
    def find(id, &block)
      # set values from block
      instance_eval &block if block_given?


      query_params = { :qt => 'standard', :q => "-#{id}:[* TO *]" }
      query_params[:rows] = @rows.present? ? @rows : '10'
      query_params[:fq] = "provider_id:\"#{provider_uri}\""
      query_params[:start] = @start if @start.present? if
        provider_id.present?

      Krikri::SolrResponseBuilder.new(query_params).response
    end

    private

    def provider_uri
      return unless provider_id.present?
      Krikri::Provider.new(provider_id).rdf_subject
    end
  end
end
