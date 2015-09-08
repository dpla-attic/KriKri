require 'spec_helper'

describe 'krikri/admin_dashboard/index.html.erb', type: :view do
  before do
  end

  it 'renders page' do
    render
    expect(rendered).not_to be_empty
  end
end
