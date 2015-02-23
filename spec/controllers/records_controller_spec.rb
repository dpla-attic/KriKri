require 'spec_helper'

describe Krikri::RecordsController, :type => :controller do
  routes { Krikri::Engine.routes }

  describe 'GET #index' do
    login_user

    let(:user_query) { 'history' }

    it 'renders the index view' do
      get :index, q: user_query
      expect(response).to render_template('krikri/records/index')
    end

    it 'gives a solr response' do
      get :index, q: user_query
      expect(assigns[:response]).to be_a Blacklight::SolrResponse
    end

    it 'responds to json requests' do
      get :index, q: user_query, format: 'json'
      expect { JSON.parse(response.body) }.not_to raise_error
    end
  end

  describe 'GET #show' do
    login_user

    before do
      indexer = Krikri::QASearchIndex.new
      indexer.add agg.to_jsonld['@graph'].first
      indexer.commit
    end

    let(:agg) do
      a = build(:aggregation)
      a.set_subject! doc_id
      a
    end

    let(:doc_id) { '123' }

    it 'renders show view' do
      get :show, id: doc_id
      expect(response).to render_template('krikri/records/show')
    end

    it 'gets document by local name' do
      get :show, id: doc_id
      expect(assigns[:document][:id]).to eq agg.rdf_subject.to_s
    end
  end
end
