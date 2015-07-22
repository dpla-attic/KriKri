require 'spec_helper'

describe 'krikri/providers/index.html.erb', type: :view do
  before do
    assign(:providers, providers)
    link_texts = providers.map { |p| "#{p.id}_LINK" }
    allow(view).to receive(:link_to).and_return(*link_texts)
  end

  let(:providers) do
    [build(:krikri_provider, rdf_subject: '123'),
     build(:krikri_provider,
           rdf_subject: 'TooTickyLibrary',
           name: 'Too-Ticky')]
  end

  it 'renders each provider' do
    render
    providers.each do |provider|
      expect(rendered).to include "#{provider.id}_LINK"
    end
  end
end
