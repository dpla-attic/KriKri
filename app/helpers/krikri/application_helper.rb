module Krikri
  module ApplicationHelper

    def current_provider_id
      return params[:provider_id] if params[:provider_id].present?
      return session[:provider_id] if session[:provider_id].present?
      return "All providers"
    end

    # TODO: Make this the name of the provider instead of the id 
    def current_provider_name
      current_provider_id
    end

  end
end
