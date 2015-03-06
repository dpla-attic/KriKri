require 'spec_helper'

describe Krikri::ModsParser do
  subject { Krikri::ModsParser.new(record) }
  let(:record) { build(:mods_record) }

  it_behaves_like 'a parser'
  it_behaves_like 'a parser with oai headers'
end
