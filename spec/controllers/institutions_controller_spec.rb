require 'spec_helper'
require 'database_cleaner'

describe Krikri::InstitutionsController, :type => :controller do

  routes { Krikri::Engine.routes }
  let(:harvest_source) { create(:krikri_harvest_source) }
  let(:institution) { harvest_source.institution }

  before(:all) do
    # This clean statement is a safety precaution
    # Occasionally there is an extra institution written to the test db
    # for a reason I am yet to ascertain
    DatabaseCleaner.clean_with(:truncation)
  end

  describe 'GET #index' do
    login_user

    it 'assigns all institutions to @institutions' do
      get :index
      expect(assigns(:institutions)).to eq([institution])
    end

    it 'renders the :index view' do
      get :index
      expect(response).to render_template('krikri/institutions/index')
    end

  end

  describe 'GET #show' do
    login_user

    it 'assigns the requested institution to @institution' do
      get :show, id: institution.id
      expect(assigns(:institution)).to eq(institution)
    end

    it 'assigns associated harvest sources to @harvest_sources' do
      get :show, id: institution.id
      expect(assigns(:harvest_sources)).to eq([harvest_source])
    end

    it 'renders the :show view' do
      get :show, id: institution.id
      expect(response).to render_template('krikri/institutions/show')
    end
  end

  describe '#update' do
    login_user
    it 'updates the institution' do
      institution
      patch :update,
            id: institution.id,
            institution: { name: 'Something Else' }
      institution.reload
      expect(institution.name).to eq('Something Else')
    end
  end

end
