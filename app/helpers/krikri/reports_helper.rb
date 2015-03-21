module Krikri
  module ReportsHelper
    
    def render_validation_report(report)
      return validation_report_title(report) if report.items.first.hits == 0
      link_to validation_report_title(report), { :controller => 
        'validation_reports', :action => 'show', :id => report.name,
        :provider => @current_provider }, :method => :get
    end

    def validation_report_title(report)
      return "#{report.name} missing (#{report.items.first.hits} record)" if
        report.items.first.hits == 1
      "#{report.name} missing (#{report.items.first.hits} records)"
    end
  end
end
