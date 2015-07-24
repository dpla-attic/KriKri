require 'spec_helper'

describe Krikri::ReportsController, :type => :controller do
  routes { Krikri::Engine.routes }

  describe 'GET #index' do
    login_user

    before do
      # @todo: Krikri::ValidationReport should be refactored to avoid the need
      #   for all this mocking.
      allow(Krikri::ValidationReport).to receive(:new).and_return(report)
      allow(report).to receive(:provider_id=)
      allow(report).to receive(:all).and_return(validation_reports)

      allow(Krikri::QAReport).to receive(:find_by).with(provider: provider_id)
                                  .and_return(qa_reports)
    end

    let(:validation_reports) do
      [double('validation report 1'), double('validation report 2')]
    end

    let(:qa_reports) { [double('qa report 1'), double('qa report 2')] }

    let(:provider_id) { 'moomin' }

    # @todo: remove me; see other comments
    let(:report) { instance_double(Krikri::ValidationReport) }

    it 'renders the index view' do
      get :index
      expect(response).to render_template('krikri/reports/index')
    end

    it 'sets current provider' do
      expect { get :index, provider: provider_id }
        .to change { assigns(:current_provider) }.to(provider_id)
    end

    it 'populates the validation reports list' do
      expect { get :index, provider: provider_id }
        .to change { assigns(:validation_reports) }.to(validation_reports)
    end

    it 'sets @provider' do
      provider = double('provider')
      allow(Krikri::Provider).to receive(:find).with(provider_id)
        .and_return(provider)
      expect { get :index, provider: provider_id }
        .to change { assigns(:provider) }.to(provider)
    end

    # @todo: this specifies implementation, due to limitations of the
    #   Krikri::ValidationReport interface (see above). Refactor me!
    it 'sets the provider' do
      expect(report).to receive(:provider_id=).with(provider_id)
      get :index, provider: provider_id
    end

    it 'populates the QA reports list by provider' do
      expect { get :index, provider: provider_id }
        .to change { assigns(:qa_reports) }.to (qa_reports)
    end

    it 'populates the QA reports as an array when a there is a single item' do
      allow(Krikri::QAReport).to receive(:find_by).with(provider: provider_id)
                                  .and_return(qa_reports.first)
      expect { get :index, provider: provider_id }
        .to change { assigns(:qa_reports) }.to ([qa_reports.first])
    end

    it 'populates the QA reports list to all' do
      expect(Krikri::QAReport).to receive(:all).and_return([:reports])
      expect { get :index }
        .to change { assigns(:qa_reports) }.to([:reports])
    end
  end
end
