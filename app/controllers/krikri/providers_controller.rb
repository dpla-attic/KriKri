module Krikri
  # This models a provider that is stored in Marmotta.
  class ProvidersController < ApplicationController
    before_action :session_provider

    def index
      @providers = Krikri::Provider.new.all
    end

    def show
    end

    private

    def session_provider
      session[:provider_id] = params[:id].present? ? params[:id] : nil
    end
  end
end
