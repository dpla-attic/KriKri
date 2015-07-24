require 'spec_helper'

describe Krikri::FieldValueReportsController, :type => :controller do

  routes { Krikri::Engine.routes }

  describe 'GET #show' do
    login_user

    it 'sets field_value_report variable' do
      field_value_report = [instance_double(Krikri::FieldValueReport)]
      allow(Krikri::FieldValueReport).to receive(:find)
        .and_return(field_value_report)
      expect { get :show, id: 'sourceResource_title', provider_id: '123',
               format: 'csv' }
        .to change { assigns[:field_value_report] }.to field_value_report
    end

    it 'does not render :show view in html' do
      expect do
        get :show, id: 'sourceResource_title', provider_id: '123'
      end.to raise_error(ActionController::UnknownFormat)
    end

    context 'csv' do
      include_context 'with indexed item'

      it 'returns a csv document' do
        get :show, id: 'sourceResource_title', provider_id: '123', format: 'csv'
        expect(response.content_type).to eq 'text/csv'
      end
    end
  end
end
