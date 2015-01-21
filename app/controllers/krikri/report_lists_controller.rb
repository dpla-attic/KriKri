module Krikri
  class ReportListsController < ApplicationController
    layout 'krikri/application'

    def index
      @validation_report_list = Krikri::ValidationReportList.new.report_list
    end

  end
end
