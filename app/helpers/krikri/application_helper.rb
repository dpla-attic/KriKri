module Krikri
  module ApplicationHelper
    ##
    # @return [Array<Blacklight::SolrResponse::Facets::FacetItem>]
    def available_providers
      Rails.cache.fetch('krikri/application_helper/available_providers',
                        expires_in: 1.hour,
                        race_condition_ttl: 3.minutes) do
        Krikri::Provider.all(&:reload)
      end
    end

    ##
    # @param provider [String, nil]
    # @return [String]
    def provider_name(provider)
      provider = Krikri::Provider.find(provider) if provider.is_a? String
      provider.present? ? provider.name : 'All Providers'
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
    # Link to the current page, changing the session provider the given
    # value.
    # @param provider [String, nil]
    def link_to_current_page_by_provider(provider)
      provider = Krikri::Provider.find(provider) if provider.is_a? String

      return link_to_provider_page(provider) if params[:controller] ==
                                                'krikri/providers'
      params[:provider] = provider.id
      params[:session_provider] = provider.id
      link_to provider_name(provider), params
    end

    def set_session_provider(provider)
      provider = Krikri::Provider.find(provider) if provider.is_a? String
      link_to provider_name(provider),
              krikri.provider_path(provider.id, set_session: 1),
              rel: 'nofollow'
    end

    def remove_session_provider
      link_to "All Providers",
              krikri.provider_path('clear', clear_session: 1),
              rel: 'nofollow'
    end

    ##
    # Link to the ProviderController's :index or :show route, using the given
    # provider id in the case of :show.
    # @param provider [String, nil]
    def link_to_provider_page(provider)
      return link_to(provider_name(provider), providers_path) unless provider
      return link_to provider_name(provider),
              provider_path(provider.id, set_session: provider.id)
    end
  end
end
