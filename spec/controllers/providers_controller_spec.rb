require 'spec_helper'

describe Krikri::ProvidersController, :type => :controller do

  routes { Krikri::Engine.routes }

  describe 'GET #show' do
    include_context 'with indexed item'
    login_user

    it 'sets provider variable' do
      expect { get :show, id: provider.id }
        .to change { assigns[:current_provider] }
             .to an_instance_of(Krikri::Provider)
    end

    it 'renders the :show view' do
      get :show, id: 'moomin'
      expect(response).to render_template('krikri/providers/show')
    end
  end

  describe 'GET #index' do
    login_user

    it 'renders the :show view' do
      get :index
      expect(response).to render_template('krikri/providers/index')
    end

    it 'sets providers variable' do
      providers = [instance_double(Krikri::Provider)]
      allow(Krikri::Provider).to receive(:all).and_return(providers)

      expect { get :index }.to change { assigns[:providers] }.to(providers)
    end
  end
end
