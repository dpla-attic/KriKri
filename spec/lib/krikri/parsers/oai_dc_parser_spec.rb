require 'spec_helper'

describe Krikri::OaiDcParser do
  subject { Krikri::OaiDcParser.new(record) }
  let(:record) { build(:oai_dc_record) }

  it_behaves_like 'a parser'
  it_behaves_like 'a parser with oai headers'
end
