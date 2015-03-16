# -*- coding: utf-8 -*-
require 'spec_helper'

describe Krikri::Harvesters::ApiHarvester do
  let(:args) { { uri: 'http://example.org/endpoint', api: query_opts } }
  let(:query_opts) { {} }
  subject { described_class.new(args) }

  describe '#new' do
    let(:query_opts) { { 'params' => { 'q' => :abc } } }

    it 'accepts api parameters' do
      expect(described_class.new(args)).to have_attributes(:opts => query_opts)
    end
  end



  context 'with responses' do
    let(:query_opts) { { 'params' => { 'q' => 'tags_ssim:dpla' } } }
    let(:response_string) do
      <<EOM
{ "response": {
    "numFound": 4,
    "start": 0,
    "docs": [{"record_id": "123"}]
  }
}
EOM
    end

    let(:second_response) do
      <<EOM
{ "response": {
    "numFound": 4,
    "start": 1,
    "docs": [{"record_id": "345"},
             {"record_id": "678"},
             {"record_id": "910"}]
  }
}
EOM
    end

    let(:empty_response) do
      <<EOM
{ "response": {
    "numFound": 4,
    "start": 1,
    "docs": []
  }
}
EOM
    end

    let(:single_record) do
      <<EOM
{ "response": {
    "numFound": 1,
    "start": 0,
    "docs": [{"record_id": "123"}]
  }
}
EOM
    end

    before do
      stub_request(:get, "http://example.org/endpoint?q=tags_ssim:dpla")
        .to_return(:status => 200, :body => response_string, :headers => {})
      stub_request(:get, "http://example.org/endpoint?q=tags_ssim:dpla&start=1")
        .to_return(:status => 200, :body => second_response, :headers => {})
      stub_request(:get, "http://example.org/endpoint?q=tags_ssim:dpla&start=4")
        .to_return(:status => 200, :body => empty_response, :headers => {})

      stub_request(:get, "http://example.org/endpoint?q=id:123")
        .to_return(:status => 200, :body => single_record, :headers => {})

    end

    it_behaves_like 'a harvester'

    describe '#count' do
      it 'returns a count' do
        expect(subject.count).to eq 4
      end
    end

    describe '#records' do
      it 'returns records lazily' do
        expect(subject).to receive(:request).once.with(args[:api])
                            .and_return(JSON.parse(response_string))
        subject.records.first
      end

      it 'gets all records' do
        expect(subject.records.count).to eq 4
      end
    end
  end
end
