module Krikri
  ##
  # Marshals validation reports for views.
  #
  # ValidationReportsController inherits from the host application's
  # ApplicationController.  It does not interit from Krikri's
  # ApplicationController.
  class ValidationReportsController < CatalogController
    before_action :authenticate_user!, :set_current_provider

    ##
    # ValidationReportsController has access to views in the following
    # directories:
    #   krikri/validation_reports
    #   catalog (defined in Blacklight)
    # It inherits view templates from the host application's
    # ApplicationController.  It uses krikri's application layout:
    layout 'krikri/application'

    def show
      provider_id = @current_provider
      page = params[:page]
      per_page = params[:per_page]
      @response = ValidationReport.new.find(params[:id]) do
        self.provider_id = provider_id
        self.start = page
        self.rows = per_page
      end
      @documents = @response.documents
    end

    private

    def set_current_provider
      @current_provider = params[:provider]
    end
  end
end
