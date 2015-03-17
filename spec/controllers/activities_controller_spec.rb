require 'spec_helper'
require 'database_cleaner'

module Krikri
  RSpec.describe Krikri::ActivitiesController, :type => :controller do
    routes { Krikri::Engine.routes }
    let(:activity) { create(:krikri_activity) }

    before(:all) do
      DatabaseCleaner.clean_with(:truncation)
    end

    describe "GET #index" do
      login_user

      it 'assigns all activities to @activities' do
        get :index
        expect(assigns(:activities)).to eq([activity])
      end

      it 'renders the :index view' do
        get :index
        expect(response).to render_template('krikri/activities/index')
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end
end
