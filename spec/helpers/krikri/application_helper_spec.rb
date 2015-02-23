require 'spec_helper'

describe Krikri::ApplicationHelper, :type => :helper do
  describe '#available_providers' do
    it 'gets available providers' do
      allow(Krikri::Provider).to receive(:all).and_return([:all_providers])
      expect(helper.available_providers).to eq [:all_providers]
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
