require 'spec_helper'

describe Krikri::HarvestSourcesController, :type => :controller do

  routes { Krikri::Engine.routes }
  let(:harvest_source) { create(:krikri_harvest_source) }
  let(:institution) { create(:krikri_institution) }

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

  describe '#update' do
    login_user
    it 'signifies a Bad Request when unexpected parameters are presented' do
      patch :update,
            id: harvest_source.id,
            harvest_source: { institution_id: 999 }
      expect(response).to have_http_status(:bad_request)
    end
    it 'updates the harvest source' do
      harvest_source
      patch :update,
            id: harvest_source.id,
            harvest_source: { metadata_schema: 'MODS' }
      harvest_source.reload
      expect(harvest_source.metadata_schema).to eq('MODS')  # was 'MARC'
    end
  end

  describe '#create' do
    login_user
    it 'creates a new harvest source' do
      expect do
        post :create,
             institution_id: institution.id,
             harvest_source:
               { name: 'New Source 1', source_type: 'OAI',
                 metadata_schema: 'MARC', uri: 'http://example.org/oai1',
                 notes: 'Created source one' }
      end.to change(Krikri::HarvestSource, :count).by(1)
    end
    it 'redirects to the institution upon harvest source creation' do
      post :create,
           institution_id: institution.id,
           harvest_source:
             { name: 'New Source 2', source_type: 'OAI',
               metadata_schema: 'MODS', uri: 'http://example.org/oai2',
               notes: 'Created source two' }
      expect(response).to redirect_to institution
    end
  end

  describe '#destroy' do
    login_user
    it 'destroys the given record' do
      harvest_source
      expect do
        delete :destroy, id: harvest_source.id
      end.to change(Krikri::HarvestSource, :count).by(-1)
    end
  end

  context 'with render_views' do
    render_views
    describe '#update' do
      login_user
      it 'gives feedback when an invalid URI is given' do
        patch :update,
              id: harvest_source.id,
              harvest_source: { uri: 'bogus' }
        assert_select 'div#error_explanation li', 'Uri is invalid'
      end
    end
  end

end
