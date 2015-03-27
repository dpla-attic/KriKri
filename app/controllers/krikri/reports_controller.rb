module Krikri
  class ReportsController < ApplicationController
    layout 'krikri/application'

    def index
      provider_id = @current_provider
      @validation_reports = Krikri::ValidationReport.new.all do
        self.provider_id = provider_id
      end
    end
  end
end
