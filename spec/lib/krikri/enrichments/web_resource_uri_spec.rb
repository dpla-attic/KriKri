
require 'spec_helper'

describe Krikri::Enrichments::WebResourceURI do
  it_behaves_like 'a field enrichment'
  
  describe '#enrich_value' do
    it 'with a string returns the original value' do
      value = 'moomin'
      expect(subject.enrich_value(value)).to eq value
    end

    it 'with a date returns the original value' do
      value = Date.today
      expect(subject.enrich_value(value)).to eq value
    end

    it 'with a resource returns the original value' do
      value = build(:aggregation)
      expect(subject.enrich_value(value)).to eq value
    end

    context 'with a WebResource' do
      let(:web_resource) { build(:web_resource) }
      
      it 'returns nil for blank node' do
        expect(subject.enrich_value(web_resource)).to be_nil
      end

      it 'retains value with URI' do
        web_resource.set_subject!('http://example.org/moomin')
        expect(subject.enrich_value(web_resource)).to eq web_resource
      end
    end
  end
end
