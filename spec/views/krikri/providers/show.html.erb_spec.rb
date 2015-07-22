require 'spec_helper'

describe 'krikri/providers/show.html.erb', type: :view do
  before { assign(:current_provider, provider) }

  let(:provider) { build(:krikri_provider) }

  it 'displays provider name' do
    render
    expect(rendered).to include provider.name
  end

  it 'links to records' do
    render
    expect(rendered).to include "#{krikri.records_path}?provider=#{provider.id}"
  end

  it 'links to reports' do
    render
    expect(rendered).to include "#{krikri.reports_path}?provider=#{provider.id}"
  end
end
