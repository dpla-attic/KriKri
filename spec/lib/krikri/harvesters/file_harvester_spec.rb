require 'spec_helper'

describe Krikri::Harvesters::FileHarvester do
  let(:args) { { uri: 'http://example.org/endpoint' } }
  subject { described_class.new(args) }

  it_behaves_like 'a harvester'


end
