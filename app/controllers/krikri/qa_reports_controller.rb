module Krikri
  ##
  # Handles HTTP requests for QA Reports
  #
  # @see Krikri::QAReport
  class QaReportsController < ApplicationController
    ##
    # Renders a list of current reports
    def index
      @reports = Krikri::QAReport.all
    end

    ##
    # Rendering the report as either a full `field` report or a `count` report.
    #
    # Responds to format of `text/csv` with a CSV rendering of the requested
    # report type.
    def show
      @report = Krikri::QAReport.find(params[:id])
      @type = params[:type] == 'count' ? :count : :field

      respond_to do |format|
        format.html
        format.csv { render text: @report.send("#{@type}_csv".to_sym).to_csv }
      end
    end
  end
end
