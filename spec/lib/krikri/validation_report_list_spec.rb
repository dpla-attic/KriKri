require 'spec_helper'

describe Krikri::ValidationReportList do

  let(:blacklight_config) { {} }
  let(:mock_response) { {} }

  subject do
    Krikri::ValidationReportList.new
  end

  describe '#report_list' do

    before(:each) do
      allow(Blacklight::Configuration).to receive(:new)
        .and_return(blacklight_config)
      solr_repository = object_double(
          Blacklight::SolrRepository.new(blacklight_config),
          :search => mock_response
        )
      allow(Blacklight::SolrRepository).to receive(:new).with(blacklight_config)
        .and_return(solr_repository)
    end

    context 'valid results from search engine' do

      it 'returns list of report names and link' do
        mock_response['facet_counts'] = {
          'facet_fields' => {
            'dataProvider_name' => [nil, 2]
          }
        }
        expected_report_list = [{
          :label => 'dataProvider_name (2)',
          :url => 'validation_reports?q=-dataProvider_name:[*%20TO%20*]' \
                  '&report_name=dataProvider_name'
        }]
        expect(subject.report_list).to eq(expected_report_list)
      end

    end

    context 'invalid results from search engine' do

      it 'returns nil' do
        expect(subject.report_list).to eq(nil)
      end
    end
  end
end
