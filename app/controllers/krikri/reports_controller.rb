module Krikri
  class ReportsController < ApplicationController
    include Krikri::QaProviderFilter
    layout 'krikri/application'
    before_action :session_provider

    def index
      if params[:provider_id].present?
        @validation_report_list = Krikri::ValidationReportList.new
          .report_list_by_provider(params[:provider_id]) and return
      end
      @validation_report_list = Krikri::ValidationReportList.new.report_list
    end

    private

    def session_provider
      session[:provider_id] = params[:provider_id].present? ? 
        params[:provider_id] : nil
    end
  end
end
