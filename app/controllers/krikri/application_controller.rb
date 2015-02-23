module Krikri
  class ApplicationController < ActionController::Base
    before_action :authenticate_user!, :set_current_provider

    def set_current_provider
      @current_provider = params[:provider]
    end
  end
end
