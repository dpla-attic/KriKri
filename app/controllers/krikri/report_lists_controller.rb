module Krikri
  class ReportListsController < ApplicationController
    include Krikri::QaProviderFilter
    layout 'krikri/application'

    def index
      @validation_report_list = Krikri::ValidationReportList.new.report_list
    end

    def show
      @validation_report_list = Krikri::ValidationReportList.new
          .report_list_by_provider(params[:id])
    end
  end
end
