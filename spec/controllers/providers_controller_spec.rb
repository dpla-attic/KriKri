require 'spec_helper'

describe Krikri::ProvidersController, :type => :controller do

  routes { Krikri::Engine.routes }

  describe 'GET #show' do
    login_user

    it 'sets provider session variable' do
      expect { get :show, id: 'moomin' }
        .to change { assigns[:current_provider] }.to 'moomin'
    end
  end

  describe 'GET #index' do
    login_user

    it 'sets provider session variable' do

      expect { get :index, id: 'moomin' }
        .to change { assigns[:current_provider] }.to 'moomin'
    end
  end
end
