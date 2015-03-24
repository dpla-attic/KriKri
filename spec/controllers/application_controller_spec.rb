require 'spec_helper'

describe Krikri::ApplicationController, :type => :controller do
  describe '#set_current_provider' do
    it 'shares :provider with the view' do
      controller.params[:provider] = :moomin
      expect { controller.set_current_provider }
        .to change { assigns[:current_provider] }.to(:moomin)
    end
  end
end
