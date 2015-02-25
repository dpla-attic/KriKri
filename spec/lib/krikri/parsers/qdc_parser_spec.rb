require 'spec_helper'

describe Krikri::QdcParser do
  let(:record) { build(:cdm_qdc_record) }
  subject { Krikri::QdcParser.new(record) }

  it_behaves_like 'a parser'
  it_behaves_like 'a parser with oai headers'
end
