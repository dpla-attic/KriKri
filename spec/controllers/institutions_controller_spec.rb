require 'spec_helper'
require 'database_cleaner'

describe Krikri::InstitutionsController, :type => :controller do

  routes { Krikri::Engine.routes }

  before(:all) do
    # This clean statement is a safety precaution
    # Occasionally there is an extra institution written to the test db
    # for a reason I am yet to ascertain
    DatabaseCleaner.clean_with(:truncation)
    @harvest_sources_factory = create(:krikri_harvest_sources)
    @institutions_factory = @harvest_sources_factory.institution
  end

  describe 'GET #index' do
    login_user

    it 'assigns all institutions to @institutions' do
      get :index
      expect(assigns(:institutions)).to eq([@institutions_factory])
    end

    it 'renders the :index view' do
      get :index
      expect(response).to render_template('krikri/institutions/index')
    end

  end

  describe 'GET #show' do
    login_user

    it 'assigns the requested institution to @institution' do
      get :show, id: @institutions_factory.id
      expect(assigns(:institution)).to eq(@institutions_factory)
    end

    it 'assigns associated harvest sources to @harvest_sources' do
      get :show, id: @institutions_factory.id
      expect(assigns(:harvest_sources)).to eq([@harvest_sources_factory])
    end

    it 'renders the :show view' do
      get :show, id: @institutions_factory.id
      expect(response).to render_template('krikri/institutions/show')
    end
  end

end
