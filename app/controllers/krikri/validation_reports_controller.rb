module Krikri
  class ValidationReportsController < CatalogController
    before_action :authenticate_user!, :session_provider
    layout 'krikri/application'

    def show
      provider_id = params[:provider_id]
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

    def session_provider
      session[:provider_id] = params[:provider_id].present? ? 
        params[:provider_id] : nil
    end
  end
end
