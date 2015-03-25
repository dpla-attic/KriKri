module Krikri::Concerns
  module ProviderContext
    def set_current_provider(provider_id = params[:provider])
      @current_provider = Krikri::Provider.find(provider_id)
    end
  end
end
