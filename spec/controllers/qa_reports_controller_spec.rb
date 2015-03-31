require 'spec_helper'

describe Krikri::QaReportsController, :type => :controller do
  routes { Krikri::Engine.routes }

  let(:report) { instance_double(Krikri::QAReport) }

  describe 'GET #index' do
    login_user

    let(:reports) { [report] }

    before { allow(Krikri::QAReport).to receive(:all).and_return(reports) }

    it 'renders the index view' do
      get :index
      expect(response).to render_template('krikri/qa_reports/index')
    end

    it 'populates the reports list' do
      get :index
      expect(assigns(:reports)).to eq(reports)
    end
  end

  describe 'GET #show' do
    login_user

    before do
      allow(Krikri::QAReport)
        .to receive(:find).with(report_id.to_s).and_return(report)
      allow(report).to receive(:field_csv).and_return(csv)
    end

    let(:report_id) { 123 }

    let(:csv) do
      CSV::Table.new([CSV::Row.new(['field_name', 'aggregation', 'isShownAt'],
                                   ['moomin', '123', 'http://example.org/123'])])
    end

    let(:count_csv) do
      CSV::Table.new([CSV::Row.new(['name', 'count'], ['moomin', '1'])])
    end

    it 'accepts a type ' do
      get :show, id: report_id, type: 'count'
      expect(assigns(:type)).to eq :count
    end

    context 'CSV' do
      it 'gives CSV result' do
        get :show, id: report_id, format: 'csv'
        expect(response.content_type).to eq 'text/csv'
      end

      it 'gives correct text in CSV result' do
        get :show, id: report_id, format: 'csv'
        expect(response.body).to eq csv.to_s
      end

      it 'gives count text in CSV result' do
        allow(report).to receive(:count_csv).and_return(count_csv)
        get :show, id: report_id, type: 'count', format: 'csv'
        expect(response.body).to eq count_csv.to_s
      end
    end
  end
end
