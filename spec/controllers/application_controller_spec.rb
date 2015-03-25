require 'spec_helper'

describe Krikri::ApplicationController, :type => :controller do
  describe '#set_current_provider' do
    before do
      allow(Krikri::Provider).to receive(:find).with(:moomin)
                                  .and_return(:moomin_provider)
    end

    it 'shares :provider with the view' do
      controller.params[:provider] = :moomin
      allow(Krikri::Provider).to receive(:find).with(:moomin)
                                  .and_return(:moomin_provider)
      expect { controller.set_current_provider }
        .to change { assigns[:current_provider] }.to(:moomin_provider)
    end

    it 'apcepts an argument as the find parameter' do
      expect { controller.set_current_provider(:moomin) }
        .to change { assigns[:current_provider] }.to(:moomin_provider)
    end
  end
end
