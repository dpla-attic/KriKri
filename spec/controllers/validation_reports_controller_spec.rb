require 'spec_helper'

describe Krikri::ValidationReportsController, :type => :controller do

  routes { Krikri::Engine.routes }

  describe '#show' do
    login_user

    it 'renders the :show view' do
      get :show, id: 1
      expect(response).to render_template('krikri/validation_report/show')
    end
  end
end
