module Krikri
  class ReportsController < ApplicationController
    include Krikri::QaProviderFilter
    layout 'krikri/application'

    def index
      if params[:provider_id].present?
        @validation_report_list = Krikri::ValidationReportList.new
          .report_list_by_provider(params[:provider_id]) and return
      end
      @validation_report_list = Krikri::ValidationReportList.new.report_list
    end
  end
end
