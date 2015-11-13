# -*- coding: utf-8 -*-
require 'spec_helper'

describe Krikri::Harvesters::MarcXMLHarvester do
  subject { described_class.new(args) }

  let(:args) { { uri: 'http://example.org/endpoint' } }

  describe '.expected_opts' do
    it 'has expected opts key :marcxml' do
      expect(described_class.expected_opts[:key]).to eq :marcxml
    end
  end

  describe '#content_type' do
    it 'is "text/xml"' do
      expect(subject.content_type).to eq 'text/xml'
    end
  end
  
  
end
