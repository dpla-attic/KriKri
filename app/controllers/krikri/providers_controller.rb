module Krikri
  class ProvidersController < ApplicationController
    before_action :session_provider

    # Admin Dashboard
    def index
      @providers = Krikri::Provider.new.all
    end

    # Provider Dashboard
    def show
    end

    private

    def session_provider
      session[:provider_id] = params[:id].present? ? params[:id] : nil
    end
  end
end
