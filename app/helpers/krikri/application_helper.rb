module Krikri
  module ApplicationHelper

    ##
    # @param provider [String, nil]
    # @return [String]
    def provider_name(provider)
      return "All Providers" unless provider.present?
      Krikri::Provider.new.find(provider)['provider_name']
    end

    # @return Array of Blacklight::SolrResponse::Facets::FacetItem's
    def available_providers
      Krikri::Provider.new.all
    end

    ##
    # @param uri [String]
    # @return [String]
    # Sample use:
    #   local_name('http/my_domain/0123') => '0123'
    def local_name(uri)
      uri.split('/').last.html_safe
    end

    ##
    # Link to the current page, changing the provider param or id to the given
    # value.
    # @param provider [String, nil]
    def link_to_current_page_by_provider(provider)
      return link_to_provider_page(provider) if params[:controller] == 
        'krikri/providers'
      params[:provider] = provider
      link_to provider_name(provider), params
    end

    ##
    # Link to the ProviderController's :index or :show route, using the given
    # provider id in the case of :show.
    # @param provider [String, nil]
    def link_to_provider_page(provider)
      return link_to provider_name(provider), providers_path if provider == nil
      return link_to provider_name(provider), provider_path(provider)
    end

  end
end
