module Krikri
  module ApplicationHelper
    ##
    # @return [Array<Blacklight::SolrResponse::Facets::FacetItem>]
    def available_providers
      Krikri::Provider.all
    end

    ##
    # @param provider [String, nil]
    # @return [String]
    def provider_name(provider)
      provider.present? ? provider.provider_name : "All Providers"
    end

    ##
    # Gives the last path fragment for a given URI string in HTML escaped form
    #
    # @example
    #   local_name('http://my_domain/blah/0123') => '0123'
    #
    # @param uri [#to_s] a URL formatted string to split
    # @return [String] the escaped fragment
    def local_name(uri)
      uri.to_s.split('/').last.html_safe
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
