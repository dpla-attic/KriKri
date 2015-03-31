require 'spec_helper'

describe Krikri::RecordsController, :type => :controller do
  include_context 'with indexed item'

  routes { Krikri::Engine.routes }

  let(:doc_id) { agg.rdf_subject.to_s.split('/').last }

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

    context 'with provider filter' do
      it 'sets provider id' do
        get :index, provider: provider.id
        expect(assigns[:provider_id]).to eq provider.id
      end

      it 'finds records with provider' do
        get :index, provider: provider.id
        ids = assigns[:response][:response][:docs].map { |doc| doc[:id] }
        expect(ids).to include agg.rdf_subject.to_s
      end

      it 'filters records by provider' do
        get :index, provider: 'abc'
        expect(assigns[:response][:response][:docs]).to be_empty
      end
    end
  end

  describe 'GET #show' do
    login_user

    it 'renders show view' do
      get :show, id: doc_id
      require 'pry'
      binding.pry unless assigns[:document]

      expect(response).to render_template('krikri/records/show')
    end

    it 'gets document by local name' do
      get :show, id: doc_id

      expect(assigns[:document][:id]).to eq agg.rdf_subject.to_s
    end

    context 'with provider filter' do
      it 'sets provider id' do
        get :show, id: doc_id, provider: provider.id
        expect(assigns[:provider_id]).to eq provider.id
      end
    end
  end
end
