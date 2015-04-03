module Krikri
  ##
  # Handles requests for provider dashboards for 'All Providers' and
  # individual providers by ID.
  #
  # @see Krikri::Provider
  class ProvidersController < ApplicationController
    ##
    # Renders the index view with `@providers` as an Array of {Krikri::Provider}s.
    def index
      @providers = Krikri::Provider.all
    end

    ##
    # Renders the show view for the provider given by `id`.
    def show
      if params[:set_session]
        session[:current_provider] = params[:id]
        redirect_to :back, provider: params[:id]
      elsif params[:clear_session]
        session.delete :current_provider
        redirect_to providers_path
      end
      @current_provider = Krikri::Provider.find(params[:id])
    end
  end
end
