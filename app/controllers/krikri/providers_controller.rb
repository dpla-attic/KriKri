module Krikri
  # This models a provider that is stored in Marmotta.
  class ProvidersController < ApplicationController

    def index
      @providers = Krikri::Provider.all
    end

    def show
    end

    private

    # Override ApplicationController method
    def set_current_provider
      @current_provider = params[:id]
    end
  end
end
