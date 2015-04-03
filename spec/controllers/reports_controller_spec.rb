require 'spec_helper'

describe Krikri::ReportsController, :type => :controller do
  routes { Krikri::Engine.routes }

  describe 'GET #index' do
    login_user

    before do
      allow_any_instance_of(Krikri::ValidationReport)
        .to receive(:all).and_return(validation_reports)

      allow(Krikri::QAReport).to receive(:find_by).with(provider: 'moomin')
                                  .and_return(qa_reports)
    end

    let(:validation_reports) do
      [double('validation report 1'), double('validation report 2')]
    end

    let(:qa_reports) { [double('qa report 1'), double('qa report 2')] }

    it 'renders the index view' do
      get :index
      expect(response).to render_template('krikri/reports/index')
    end

    it 'sets current provider' do
      expect { get :index, provider: 'moomin' }
        .to change { assigns(:current_provider) }.to('moomin')
    end

    it 'populates the validation reports list' do
      expect { get :index, provider: 'moomin' }
        .to change { assigns(:validation_reports) }.to(validation_reports)
    end

    it 'populates the QA reports list by provider' do
      expect { get :index, provider: 'moomin' }
        .to change { assigns(:qa_reports) }.to (qa_reports)
    end

    it 'populates the QA reports as an array when a there is a single item' do
      allow(Krikri::QAReport).to receive(:find_by).with(provider: 'moomin')
                                  .and_return(qa_reports.first)
      expect { get :index, provider: 'moomin' }
        .to change { assigns(:qa_reports) }.to ([qa_reports.first])
    end

    it 'populates the QA reports list to all' do
      expect(Krikri::QAReport).to receive(:all).and_return([:reports])
      expect { get :index }
        .to change { assigns(:qa_reports) }.to([:reports])
    end
  end
end
