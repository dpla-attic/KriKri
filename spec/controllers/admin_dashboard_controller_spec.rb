require 'spec_helper'

describe Krikri::AdminDashboardController, :type => :controller do
  routes { Krikri::Engine.routes }

  describe '#index' do
    context 'with user logged in' do
      login_user
      
      it do
        get :index
      end
    end
  end
end
