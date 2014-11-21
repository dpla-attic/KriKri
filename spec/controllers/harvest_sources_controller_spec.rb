require 'spec_helper'

describe Krikri::HarvestSourcesController, :type => :controller do

  routes { Krikri::Engine.routes }

  before(:all) do
    @harvest_sources_factory = create(:krikri_harvest_sources)
  end

  describe '#show' do
    login_user

    it 'assigns the requested harvest source to @harvest_source' do
      get :show, id: @harvest_sources_factory.id
      expect(assigns(:harvest_source)).to eq(@harvest_sources_factory)
    end

    it 'renders the :show view' do
      get :show, id: @harvest_sources_factory.id
      expect(response).to render_template('krikri/harvest_sources/show')
    end
  end

end
