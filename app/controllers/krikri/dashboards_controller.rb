module Krikri
  class DashboardsController < ApplicationController
    before_action :session_provider, :only => :show

    def show
    end

    private

    def session_provider
      session[:provider] = params[:id]
    end
  end
end
