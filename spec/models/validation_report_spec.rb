require 'spec_helper'

describe Krikri::ValidationReport do
  include_context 'with indexed item'

  # @todo: need more tests for ValidationReport#all
  describe `#all` do
    it 'returns facet for each required field' do
      count = described_class::REQUIRED_FIELDS.count
      facet_field_const = Blacklight::SolrResponse::Facets::FacetField
      fields = Array.new(count, an_instance_of(facet_field_const))

      expect(subject.all).to contain_exactly(*fields)
    end
  end

  # @todo: need more tests for ValidationReport#find
  describe `#find` do
    it 'gives a blacklight solr response' do
      expect(subject.find('sourceResource_title'))
        .to be_a Blacklight::SolrResponse
    end

    it 'raises an error for invalid fields' do
      expect { subject.find('notA_field') }
        .to raise_error RSolr::Error::Http
    end

    it 'gets by provider_id' do
      provider_uri = RDF::URI(Krikri::Settings.prov.provider_base) / '123'
      params = { :qt => 'standard',
                 :q => '-sourceResource_title:[* TO *]',
                 :rows => '10',
                 :fq => "provider_id:\"#{provider_uri}\"" }


      response = double('solr response')
      allow(Krikri::SolrResponseBuilder).to receive(:new).with(params)
                                             .and_return(response)
      allow(response).to receive(:response).and_return(:result)

      result = subject.find('sourceResource_title') do
        self.provider_id = '123'
      end

      expect(result).to eq :result
    end
  end
end
