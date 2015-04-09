require 'spec_helper'

describe Krikri::Enrichments::SplitCoordinates do
  it_behaves_like 'a field enrichment'

  context 'with place object' do
    let(:lat) { nil }
    let(:long) { nil }
    let(:place) { build(:place, lat: lat, long: long) }

    shared_examples 'latitude and longitude' do |expected_lat, expected_long|
      it 'assigns latitude' do
        expect(subject.enrich_value(place).lat).to eq expected_lat
      end
      it 'assigns longitude' do
        expect(subject.enrich_value(place).long).to eq expected_long
      end
    end

    shared_examples 'nonsensical coordinates' do
      it 'retains original coordinates' do
        rv = subject.enrich_value(place)
        expect(rv.lat).to eq [lat].compact
        expect(rv.long).to eq [long].compact
      end
    end

    context 'with latitude first' do
      let(:lat) { '40.7127,74.0059' }
      include_examples 'latitude and longitude', ['40.7127'], ['74.0059']
    end

    context 'with longitude first' do
      let(:long) { '40.7127,74.0059' }
      include_examples 'latitude and longitude', ['74.0059'], ['40.7127']
    end

    context 'with a space character' do
      let(:lat) { '40.7127, 74.0059' }
      include_examples 'latitude and longitude', ['40.7127'], ['74.0059']
    end

    context 'with a latitude that does not split' do
      let(:lat) { '40.0' }
      include_examples 'nonsensical coordinates'
    end

    context 'with a latitude that splits into too many values' do
      let(:lat) { '1.0,2.0,3.0' }
      include_examples 'nonsensical coordinates'
    end

    context 'with a latitude containing non-decimal characters' do
      let(:lat) { '10.0,10;' }
      include_examples 'nonsensical coordinates'
    end
  end  # context 'with place object'

  context 'with something other than a place object' do
    it 'returns the given object' do
      val = 'something'
      expect(subject.enrich_value(val)).to equal val
    end
  end
end
