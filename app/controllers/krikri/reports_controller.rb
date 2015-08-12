module Krikri
  ##
  # Handles HTTP requests for the Reports dashboard, presenting all types of
  # reports, filtered by {Krikri::Provider} if given.
  class ReportsController < ApplicationController
    layout 'krikri/application'

    ##
    # Renders the index view, giving `@validation_reports` and `@qa_reports`
    # for the specified provider.
    def index
      @current_provider = params[:provider]
      report = Krikri::ValidationReport.new
      report.provider_id = @current_provider
      @validation_reports = report.all

      if @current_provider
        @provider = Krikri::Provider.find(@current_provider)
        @qa_reports = Array(Krikri::QAReport.find_by(provider: @current_provider))
      else
        @qa_reports = Krikri::QAReport.all
      end
    end
  end
end
