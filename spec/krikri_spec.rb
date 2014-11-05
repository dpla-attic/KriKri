require 'spec_helper'

describe Krikri::Engine do
  describe 'configuration' do
    before do
      settings_path =
        Krikri::Engine.root.join('config', 'settings.local.yml').to_s
      File.stub(:exists?).and_call_original
      File.stub(:exists?).with(settings_path).and_return(true)
      IO.stub(:read).and_call_original
      IO.stub(:read).with(settings_path)
        .and_return("---\n\nqa_test: 'test!'")

      Krikri::Settings.reload!
    end

    it 'includes its settings in rails_config' do
      expect(Krikri::Settings.qa_test).to eq 'test!'
    end

    it 'allows app to override configuration' do
      app_settings_path = Rails.root.join('config', 'settings.local.yml').to_s
      File.stub(:exists?).with(app_settings_path).and_return(true)
      IO.stub(:read).with(app_settings_path)
        .and_return("---\n\napi_test: 'app!'")
      Krikri::Settings.reload!

      expect(Krikri::Settings.api_test).to eq 'app!'
    end
  end
end
