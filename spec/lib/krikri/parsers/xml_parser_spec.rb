require 'spec_helper'

describe Krikri::XmlParser do
  subject { Krikri::XmlParser.new(record) }
  let(:record) { build(:oai_dc_record) }

  it_behaves_like 'a parser'

  context 'with a root path' do
    subject { Krikri::XmlParser.new(record, '//oai_dc:dc') }

    it_behaves_like 'a parser'
  end
end

describe Krikri::XmlParser::Value do
  subject { Krikri::XmlParser.new(record).root }
  let(:record) { build(:oai_dc_record) }

  it_behaves_like 'a parser value'
end
