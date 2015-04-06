require 'spec_helper'

describe Krikri::ValidationReportsController, :type => :controller do

  routes { Krikri::Engine.routes }

  describe '#show' do
    login_user

    it 'renders the :show view' do
      get :show, id: 'sourceResource_title', provider: 'nypl'
      expect(response).to render_template('krikri/validation_reports/show')
    end

    it 'sets current provider' do
      expect { get :show, id: 'sourceResource_title', provider: 'nypl' }
        .to change { assigns(:current_provider) }.to('nypl')
    end
  end
end
