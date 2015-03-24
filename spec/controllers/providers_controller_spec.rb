require 'spec_helper'

describe Krikri::ProvidersController, :type => :controller do

  routes { Krikri::Engine.routes }

  describe 'GET #show' do
    login_user

    it 'sets provider session variable' do
      get :show, id: 'Sample Provider'
      expect(session[:provider]).to eq('Sample Provider')
    end
  end
end
