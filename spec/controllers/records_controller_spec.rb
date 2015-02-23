require 'spec_helper'

describe Krikri::RecordsController, :type => :controller do

  routes { Krikri::Engine.routes }

  describe 'GET #index' do
    login_user

    context 'without session provider' do
      it 'redirects to /krikri/admin#index' do
        get :index
        expect(response).to redirect_to('/krikri/admin')
      end
    end
  end

  describe 'GET #show' do
    login_user

    context 'without session provider' do
      it 'redirects to /krikri/admin#index' do
        get :show, id: '123'
        expect(response).to redirect_to('/krikri/admin')
      end
    end
  end
end
