require 'spec_helper'

describe Krikri::ApplicationHelper, :type => :helper do
  describe '#available_providers' do
    it 'gets available providers' do
      allow(Krikri::Provider).to receive(:all).and_return([:all_providers])
      expect(helper.available_providers).to eq [:all_providers]
    end
  end

  describe '#provider_name' do
    let(:provider) { double('provider') }
    let(:name) { double('name') }

    it 'finds provider for id if string is given' do
      allow(provider).to receive(:provider_name).and_return(name)
      expect(Krikri::Provider).to receive(:find).and_return(provider)
      expect(helper.provider_name('provider')).to eq name
    end

    it 'gives provider name' do
      allow(provider).to receive(:provider_name).and_return(name)
      expect(helper.provider_name(provider)).to eq name
    end

    it 'returns string if no providers given' do
      expect(helper.provider_name(nil)).to be_a String
    end
  end

  describe '#local_name' do
    let(:uri) { 'http://example.org/blah/moomin' }
    let(:stub) { 'moomin' }

    it 'splits string' do
      expect(helper.local_name(uri)).to eq stub
    end

    it 'splits URI' do
      expect(helper.local_name(RDF::URI(uri))).to eq stub
    end
  end
end
