module Krikri
  module ApplicationHelper

    def current_provider_id
      return session[:provider_id].present? ? session[:provider_id] : nil
    end

    # TODO: Make this the name of the provider instead of the id 
    def current_provider_name
      return current_provider_id.present? ? current_provider_id : 
        "All providers"
    end

    ##
    # Returns all providers that are not currently set as session provider
    # @return Array of Blacklight::SolrResponse::Facets::FacetItem's
    # TODO return names of providers along with ids
    def available_providers
      Krikri::Provider.new.all.delete_if { |p| p.value == current_provider_id }
    end
  end
end
