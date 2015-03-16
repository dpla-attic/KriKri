module Krikri
  # This module allows QA tasks to be performed for one provider at a time.
  module QaProviderFilter
    ##
    # To add this functionality to a controller that inherits from
    # Blacklight::CatalogController, include this module and add:
    #   self.solr_search_params_logic += [:records_by_provider]

    ##
    # This method is intended for use in a controller, so it assumes access
    # to session variables.
    # @param [Hash] solr_parameters a hash of parameters to be sent to Solr.
    # @param [Hash] user_parameters a hash of user-supplied parameters.
    def records_by_provider(solr_params, user_params)
      if params[:provider_id].present?
        solr_params[:fq] ||= []
        solr_params[:fq] << provider_fq(params[:provider_id])
      end
    end

    ##
    # Returns the :fq param that will filter a solr query by provider.
    # @param String
    # @return String
    # @example:
    #   query_params = { :fq => provider_fq("Boston Public Library") }
    def provider_fq(provider)
      "provider_id:\"#{provider}\""
    end
  end
end
