require 'spec_helper'

describe 'krikri/records/show.html.erb', type: :view do

  before do
    assign(:provider_id, provider.id)
    assign(:document, document)

    allow(document).to receive(:id).and_return(document_id)
    allow(view).to receive(:render_enriched_record).with(document)
                    .and_return(enriched_record)
    allow(view).to receive(:render_original_record).with(document)
                    .and_return(original_record)

    # this is a very weak test setup
    allow(view).to receive(:provider_name).with(provider.id)
    allow(view).to receive(:random_record_id).with(provider.id)
                    .and_return('moomin')
    allow(view).to receive(:link_to).and_return(random_record)
  end

  let(:provider) { build(:krikri_provider) }
  let(:document) { double('Blacklight Document') }
  let(:document_id) { 'moomin' }
  let(:enriched_record) { 'Enriched Record' }
  let(:original_record) { 'Original Record' }
  let(:random_record) { 'RANDOM RECORD LINK' }

  it 'shows document id' do
    render
    expect(rendered).to include document_id.html_safe
  end

  # this is a very weak test
  it 'links to random record from this provider' do
    render
    expect(rendered).to include random_record
  end

  it 'renders enriched record' do
    render
    expect(rendered).to include enriched_record
  end

  it 'renders original record' do
    render
    expect(rendered).to include original_record
  end
end
