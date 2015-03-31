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
      @validation_reports = Krikri::ValidationReport.new.all do
        self.provider_id = @current_provider
      end

      if @current_provider
        @qa_reports = Array(Krikri::QAReport.find_by(provider: @current_provider))
      else
        @qa_reports = Krikri::QAReport.all
      end
    end
  end
end
