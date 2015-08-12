module Krikri
  ##
  # Handles HTTP requests for Field Value Reports
  #
  # @see Krikri::FieldValueReport
  class FieldValueReportsController < ApplicationController
    ##
    # Renders the show view for the field value report, given by a compound key.
    # The compound key is comprised by the field value report's field
    # (represented by the route's id param) and the provider's id.

    def show
      @field_value_report = Krikri::FieldValueReport.find(params[:id], 
                                                          params[:provider_id])

      respond_to do |format|
        format.csv
      end
    end
  end
end
