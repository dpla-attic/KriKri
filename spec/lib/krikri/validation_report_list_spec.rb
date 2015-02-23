require 'spec_helper'

describe Krikri::ValidationReportList do

  subject do
    Krikri::ValidationReportList.new
  end

  describe '#report_link' do
    it 'returns link label and url' do
      expected_link = { label: 'provider_id (2)',
                        url: 'validation_reports?q=-provider_id:[*%20TO%20*]' \
                             '&report_name=provider_id' }
      expect(subject.send(:report_link, 'provider_id', 2)).to eq(expected_link)
    end
  end
end
