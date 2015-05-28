require 'spec_helper'

describe Krikri::JsonParser do
  subject { Krikri::JsonParser.new(record) }
  let(:record) { build(:json_record) }

  it_behaves_like 'a parser'

  context 'with a root path that specifies an array' do
    subject { Krikri::JsonParser.new(record, '$.contributor') }
    it_behaves_like 'a parser'
  end

  context 'with a root path with that specifies a key in an array' do
    subject { Krikri::JsonParser.new(record, '$.contributor[0]') }
    it_behaves_like 'a parser'
  end

  context 'with a root path that specifies an object' do
    subject { Krikri::JsonParser.new(record, '$.translations') }
    it_behaves_like 'a parser'
  end
end

describe Krikri::JsonParser::Value do
  subject { Krikri::JsonParser.new(record).root }
  let(:record) { build(:json_record) }

  it_behaves_like 'a parser value'

  it 'allows boolean "or" with "|" in the field name' do
    expect(subject['notdefined|subject'].values).to eq ["Moomin Papa"]
  end

  it 'returns the value from the first defined name, given a "|"' do
    # "subject" comes last in the document, but first in the "|" expression:
    expect(subject['subject|title'].values).to eq ["Moomin Papa"]
  end
end
