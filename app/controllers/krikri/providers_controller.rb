module Krikri
  class ProvidersController < ApplicationController
    before_action :session_provider, :only => :show

    # Admin Dashboard
    def index
      @providers = Krikri::Provider.new.all
    end

    # Provider Dashboard
    def show
    end

    private

    def session_provider
      session[:provider] = params[:id]
    end

  end
end