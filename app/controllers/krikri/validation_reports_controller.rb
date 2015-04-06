module Krikri
  ##
  # Marshals validation reports for views.
  #
  # ValidationReportsController inherits from the host application's
  # ApplicationController.  It does not interit from Krikri's
  # ApplicationController.
  class ValidationReportsController < CatalogController
    before_action :authenticate_user!

    ##
    # ValidationReportsController has access to views in the following
    # directories:
    #   krikri/validation_reports
    #   catalog (defined in Blacklight)
    # It inherits view templates from the host application's
    # ApplicationController.  It uses krikri's application layout:
    layout 'krikri/application'

    ##
    # Render the show view
    #
    # This differs from {Blacklight::CatalogController}'s normal handling of the
    # index and show views, Giving a paginated list of response documents
    # instead of showing a single document.
    #
    # @todo: consider bringing this in line with Blacklight's approach
    def show
      @current_provider = params[:provider]

      @response = build_report.find(params[:id])
      @documents = @response.documents
    end

    private

    def build_report
      report = ValidationReport.new
      report.provider_id = @current_provider
      report.page = params[:page]
      report.rows = params[:per_page]
      report
    end
  end
end
