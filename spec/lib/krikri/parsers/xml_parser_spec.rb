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
  it_behaves_like 'a parser value that has attributes'

  context 'with a root path' do
    subject { Krikri::XmlParser.new(record, '//oai_dc:dc').root }

    it 'allows boolean "or" with "|" in the field name' do
      expect(subject['dc:notdefined|dc:type'].values).to eq ["model"]
    end

    it 'returns the value from the first defined name, given a "|"' do
      # "dc:type" comes last in the document, but comes first in the "|"
      # expression:
      expect(subject['dc:type|dc:title'].values)
        .to eq ["model"]
    end
  end
end
