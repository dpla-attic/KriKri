module Krikri
  class ValidationReportsController < CatalogController
    include Krikri::QaProviderFilter
    before_action :authenticate_user!, :session_provider
    layout 'krikri/application'

    def show
      provider_id = params[:provider_id]
      @response = ValidationReport.new.find(params[:id]) do
        self.provider_id = provider_id
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
