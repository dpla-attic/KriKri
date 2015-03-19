require 'spec_helper'

describe Krikri::Enrichments::DedupValues do
  it_behaves_like 'a field enrichment'

  let(:value) { build(:source_resource) }

  context 'with non-resource value' do
    let(:value) { 'moomin' }

    it 'leaves the value unchanged' do
      expect(subject.enrich_value(value)).to eq value
    end
  end

  context 'with resource values' do
    it 'retains single values' do
      start_values = value.creator.dup
      expect(subject.enrich_value(value).creator)
        .to contain_exactly(*start_values)
    end

    context 'with multiple values' do
      it 'collapses multiple values with same providedLabel' do
        start_values = value.creator.dup
        new_creator = DPLA::MAP::Agent.new
        new_creator.providedLabel = value.creator.first.providedLabel
        value.creator << new_creator
        expect(subject.enrich_value(value).creator)
          .to contain_exactly(*start_values)
      end

      it 'retains literal values when collapsing' do
        value.creator << 'moomin'
        start_values = value.creator.dup
        new_creator = DPLA::MAP::Agent.new
        new_creator.providedLabel = value.creator.first.providedLabel
        value.creator << new_creator
        expect(subject.enrich_value(value).creator)
          .to contain_exactly(*start_values)
      end
    end
  end
end
