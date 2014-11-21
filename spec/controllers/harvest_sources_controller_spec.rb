require 'spec_helper'

describe Krikri::HarvestSourcesController, :type => :controller do

  routes { Krikri::Engine.routes }
  let (:harvest_source) { create(:krikri_harvest_source) }

  describe '#show' do
    login_user

    it 'assigns the requested harvest source to @harvest_source' do
      get :show, id: harvest_source.id
      expect(assigns(:harvest_source)).to eq(harvest_source)
    end

    it 'renders the :show view' do
      get :show, id: harvest_source.id
      expect(response).to render_template('krikri/harvest_sources/show')
    end
  end

end
