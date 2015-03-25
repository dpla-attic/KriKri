require 'spec_helper'

describe Krikri::ProvidersController, :type => :controller do

  routes { Krikri::Engine.routes }

  describe 'GET #show' do
    login_user

    it 'sets provider variable' do
      expect { get :show, id: 'moomin' }
        .to change { assigns[:current_provider] }
             .to an_instance_of(Krikri::Provider)
    end
  end

  describe 'GET #index' do
    login_user

    it 'sets provider variable' do
      expect { get :index, id: 'moomin' }
        .to change { assigns[:current_provider] }
             .to an_instance_of(Krikri::Provider)
    end

    it 'renders the :show view' do
      get :show, id: 'moomin'
      expect(response).to render_template('krikri/providers/show')
    end
  end
end
