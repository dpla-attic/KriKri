module Krikri
  # This module allows QA tasks to be performed for one provider at a time.
  module QaProviderFilter
    ##
    # To add this functionality to a controller that inherits from
    # Blacklight::CatalogController, include this module and add:
    #   self.solr_search_params_logic += [:records_by_provider]
    #
    # Optionally, add :authenticate_session_provider as a before_action to any
    # controller.

    ##
    # This method is intended for use in a controller, so it assumes access
    # to session variables.
    # @param [Hash] solr_parameters a hash of parameters to be sent to Solr.
    # @param [Hash] user_parameters a hash of user-supplied parameters.
    def records_by_provider(solr_params, user_params)
      solr_params[:fq] ||= []
      solr_params[:fq] << provider_fq(session[:provider])
    end

    ##
    # If a session provider has not been assigned, redirect to admin#index.
    # This method is intended for use in a controller, so it assumes access
    # to session variables.
    def authenticate_session_provider
      flash[:message] = 'Select a provider to perform QA tasks.'
      redirect_to url_for(controller: :admin, action: :index) unless
        session[:provider].present?
    end

    ##
    # Returns the :fq param that will filter a solr query by provider.
    # @param String
    # @return String
    # @example:
    #   query_params = { :fq => provider_fq("Boston Public Library") }
    def provider_fq(provider)
      "provider_name:\"#{provider}\""
    end
  end
end
