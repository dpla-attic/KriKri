require 'spec_helper'

describe Krikri::Engine do
  describe 'configuration' do
    before do
      settings_path =
        Krikri::Engine.root.join('config', 'settings.local.yml').to_s
      allow(File).to receive(:exists?).and_call_original
      allow(File).to receive(:exists?).with(settings_path).and_return(true)
      allow(IO).to receive(:read).and_call_original
      allow(IO).to receive(:read).with(settings_path)
        .and_return("---\n\nqa_test: 'test!'")

      Krikri::Settings.reload!
    end

    it 'includes its settings in rails_config' do
      expect(Krikri::Settings.qa_test).to eq 'test!'
    end

    it 'sets RDF::URI::CACHE_SIZE' do
      expect(RDF::URI::CACHE_SIZE).not_to eq -1
    end

    it 'sets RDF::URI.cache capacity' do
      expect(RDF::URI.cache).to have_capacity
    end

    it 'allows app to override configuration' do
      app_settings_path = Rails.root.join('config', 'settings.local.yml').to_s
      allow(File).to receive(:exists?).with(app_settings_path).and_return(true)
      allow(IO).to receive(:read).with(app_settings_path)
        .and_return("---\n\napi_test: 'app!'")
      Krikri::Settings.reload!

      expect(Krikri::Settings.api_test).to eq 'app!'
    end

    describe '#configure_blacklight!' do
      before do
        @old_solr_config = Blacklight.solr_config
      end

      after do
        Blacklight.solr_config = @old_solr_config
      end

      it 'merges solr settings with blacklight settings' do
        uri = 'http://moomin.org/'
        allow(Krikri::Settings).to receive(:solr).and_return(url: uri)
        described_class.configure_blacklight!
        expect(Blacklight.solr_config[:url]).to eq uri
      end

      it 'does not destroy blacklight config options not provided by Krikri' do
        allow(Krikri::Settings).to receive(:solr).and_return(nil)
        described_class.configure_blacklight!
        expect(Blacklight.solr_config[:url]).not_to be_nil
      end
    end
  end
end
