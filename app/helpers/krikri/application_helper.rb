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
  end
end
