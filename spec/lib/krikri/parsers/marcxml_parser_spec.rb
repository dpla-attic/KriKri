require 'spec_helper'

describe Krikri::MARCXMLParser do
  subject { Krikri::MARCXMLParser.new(record) }
  let(:record) { build(:marcxml_record) }

  it_behaves_like 'a parser'
  it_behaves_like 'a parser with oai headers'
end
