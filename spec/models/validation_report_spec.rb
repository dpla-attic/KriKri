require 'spec_helper'

describe Krikri::ValidationReport do
  describe `#all` do
    it 'returns facet for each required field' do
      count = described_class::REQUIRED_FIELDS.count
      facet_field_const = Blacklight::SolrResponse::Facets::FacetField
      fields = Array.new(count, an_instance_of(facet_field_const))

      expect(subject.all).to contain_exactly(*fields)
    end

    context 'with missing value in record' do
      include_context 'with missing values'

      it 'returns facets by provider' do
        subject.provider_id = provider.id
        hits = subject.all.select { |fct| fct.name == 'sourceResource_title' }
               .first.items.first.hits

        expect(hits).to eq 1
      end
    end
  end

  describe `#find` do
    it 'gives a blacklight solr response' do
      expect(subject.find('sourceResource_title'))
        .to be_a Blacklight::SolrResponse
    end

    it 'raises an error for invalid fields' do
      expect { subject.find('notA_field') }
        .to raise_error RSolr::Error::Http
    end

    context 'with missing values in record' do
      include_context 'with missing values'

      it 'gets docs for all providers' do
        docs = subject.find('sourceResource_title').response['docs']

        expect(docs.map { |d| d['id'] })
          .to contain_exactly(empty.rdf_subject.to_s,
                              empty_new_provider.rdf_subject.to_s)
      end

      context 'with provider set' do
        before { subject.provider_id = provider.id }

        it 'gets by provider_id' do
          expect(subject.find('sourceResource_title').response['numFound'])
            .to eq 1
        end

        it 'gets docs by provider_id' do
          subject.provider_id = provider.id
          docs = subject.find('sourceResource_title').response['docs']

          expect(docs.map { |d| d['id'] })
            .to contain_exactly empty.rdf_subject.to_s
        end
      end
    end
  end
end
