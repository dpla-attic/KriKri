module Krikri
  class ReportListsController < ApplicationController
    include Krikri::QaProviderFilter
    before_action :authenticate_session_provider
    layout 'krikri/application'

    def index
      @validation_report_list = Krikri::ValidationReportList.new
        .report_list_by_provider(session[:provider])
    end
  end
end
