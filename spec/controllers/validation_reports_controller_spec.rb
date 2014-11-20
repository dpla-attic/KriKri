require 'spec_helper'

describe Krikri::ValidationReportsController, :type => :controller do

  routes { Krikri::Engine.routes }

  describe 'GET #index' do
    login_user

    it 'redirects to /krikri/report_lists#index in absence of valid params' do
      get :index
      expect(response).to redirect_to('/krikri/report_lists')
    end
  end

end
