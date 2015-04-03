require 'spec_helper'

describe 'krikri/reports/index.html.erb', type: :view do
  before do
    assign(:current_provider, provider)
    assign(:validation_reports, [])
    assign(:qa_reports, [])
  end

  let(:provider) { build(:krikri_provider) }

  it 'displays provider name' do
    render
    expect(rendered).to include provider.label.first
  end

  it 'renders validation reports' do
    render
    expect(rendered).to include 'Validation Reports'
  end

  it 'renders qa reports' do
    render
    expect(rendered).to include 'QA Reports'
  end
end
