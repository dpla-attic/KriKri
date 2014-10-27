require 'spec_helper'

describe Krikri::IndexService do

  subject { Krikri::IndexService }
  let(:solr) { RSolr.connect }

  describe '#solr_doc' do
    it 'converts JSON into Solr-compatible hash' do
      json = { 'a' => '1', 'b' => { 'c' => '2', 'd' => '3' } }.to_json
      flat_hash = { 'a' => '1', 'b_c' => '2', 'b_d' => '3' }
      result = subject.class_eval { solr_doc(json) }
      expect(result).to eq flat_hash
    end

    it 'removes special character strings from keys' do
      json = {
        'http://www.geonames.org/ontology#a' => '1',
        'http://www.w3.org/2003/01/geo/wgs84_pos#b' => '2',
        '@c' => '3'
      }.to_json
      flat_hash = { 'a' => '1', 'b' => '2', 'c' => '3' }
      result = subject.class_eval { solr_doc(json) }
      expect(result).to eq flat_hash
    end

    context 'with models' do
      let(:aggregation) { build(:aggregation) }

      before do
        aggregation.set_subject!('http://api.dp.la/item/123')
        Krikri::IndexService.add aggregation.to_jsonld['@graph'][0].to_json
        Krikri::IndexService.commit
      end

      after do
        q = 'id:*'
        Krikri::IndexService.delete_by_query(q)
        Krikri::IndexService.commit
      end

      it 'posts DPLA MAP JSON to solr' do
        response = solr.get('select', :params => { :q => '' })['response']
        expect(response['numFound']).to eq 1
      end
    end
  end
end
