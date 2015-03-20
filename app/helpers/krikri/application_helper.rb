module Krikri
  module ApplicationHelper

    def current_provider_id
      return session[:provider_id].present? ? session[:provider_id] : nil
    end

    # TODO: Make this the name of the provider instead of the id 
    def current_provider_name
      return "All Providers" unless current_provider_id.present?
      Krikri::Providers.new.find(current_provider_id)['provider_name']
    end

    def provider_name(provider)
      return "All Providers" unless provider.present?
      provider
    end

    ##### INSTEAD javascript function when dropdown button is clicked:
    # If session-sensitve controller, change params and re-render page
    # If not, change session state and re-render page. 
    # Make other links in menu response to session state.
    ##
    # Returns all providers that are not currently set as session provider
    # @return Array of Blacklight::SolrResponse::Facets::FacetItem's
    # 
    # TODO return names of providers along with ids
    def available_providers
      Krikri::Provider.new.all.delete_if do |p| 
        local_name(p.value) == current_provider_id
      end
    end

    ##
    # @param [String]
    # @return [String]
    # Sample use:
    #   local_name('http/my_domain/0123') => '0123'
    def local_name(uri)
      uri.split('/').last.html_safe
    end

    def link_to_current_page_by_provider(provider)
      if params[:controller] == 'krikri/providers'
        return link_to_provider_page(provider)
      end

      if provider == :all
        params.delete :provider_id
        provider_name = "All Providers"
      else
        params[:provider_id] = provider
        provider_name = provider
      end

      link_to provider_name, params
    end

    ##
    # Link to the ProviderController's :index or :show route, using the given
    # provider id in the case of :show.
    # @param provider [String] a provider id
    #   Sample use: link_to_provider_page(:all)
    #   Sample use: link_to_provider_page('0123')
    def link_to_provider_page(provider)
      return link_to "All Providers", providers_path if provider == :all
      return link_to provider, provider_path(provider)
    end

  end
end
