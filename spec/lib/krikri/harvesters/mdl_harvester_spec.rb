require 'spec_helper'

describe Krikri::Harvesters::MdlHarvester do
  let(:args) { { uri: 'http://example.org/endpoint', api: query_opts } }
  let(:query_opts) { {} }
  subject { described_class.new(args) }

  describe '#new' do
    it 'uses MDL options by default' do
      expect(described_class.new)
        .to have_attributes(uri: 'http://hub-client.lib.umn.edu/api/v1/records',
                            name: 'mdl',
                            opts: { 'params' => { 'q' => 'tags_ssim:dpla' } })
    end

    it 'allows override of MDL uri' do
      uri = 'http://example.org/mdl'
      expect(described_class.new(uri: uri))
        .to have_attributes(uri: uri,
                            opts: { 'params' => { 'q' => 'tags_ssim:dpla' } })
    end

    it 'allows override of MDL params' do
      params = { 'params' => 'abc' }
      expect(described_class.new(api: params))
        .to have_attributes(uri: 'http://hub-client.lib.umn.edu/api/v1/records',
                            opts: params)
    end

    it 'allows override of MDL name' do
      harvester_name = 'moomin'
      expect(described_class.new(name: harvester_name))
              .to have_attributes(name: harvester_name)
    end
  end
end
