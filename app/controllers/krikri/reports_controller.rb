module Krikri
  class ReportsController < ApplicationController
    layout 'krikri/application'
    before_action :session_provider

    def index
      provider_id = params[:provider_id]
      @validation_reports = Krikri::ValidationReport.new.all do 
        self.provider_id = provider_id
      end
    end

    private

    def session_provider
      session[:provider_id] = params[:provider_id].present? ? 
        params[:provider_id] : nil
    end
  end
end
