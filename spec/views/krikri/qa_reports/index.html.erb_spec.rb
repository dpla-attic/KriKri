require 'spec_helper'

describe 'krikri/qa_reports/index.html.erb', type: :view do
  let(:reports) { [double, double] }
  let(:provider) { build(:krikri_provider) }

  before do
    reports.each_with_index do |report, i|
      allow(report).to receive(:id).and_return(i.to_s)
      allow(report).to receive(:build_provider)
                        .and_return(provider)

      allow(view).to receive(:qa_report_path).with(report, format: 'csv')
                      .and_return("report#{i}_csv_link")

      allow(view).to receive(:qa_report_path)
                      .with(report, format: 'csv', type: 'count')
                      .and_return("report#{i}_count_csv_link")
    end

    assign(:reports, reports)
  end

  it 'gives provider by name' do
    render
    expect(rendered).to include view.provider_name(provider)
  end

  it 'links to csv' do
    render
    reports.each do |report|
      expect(rendered).to include "#{report.id}_csv_link"
    end
  end

  it 'links to counts csv' do
    render
    reports.each do |report|
      expect(rendered).to include "#{report.id}_count_csv_link"
    end
  end
end
