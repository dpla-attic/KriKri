require 'spec_helper'

describe Krikri::Enrichments::SplitProvidedLabelAtDelimiter do
  it_behaves_like 'a field enrichment'

  describe '#enrich_value' do
    it 'skips non-resource values' do
      expect(subject.enrich_value('moomin')).to eq 'moomin'
    end

    it 'skips values with no provided label' do
      resource = ActiveTriples::Resource.new
      expect(subject.enrich_value(resource)).to eq resource
    end

    context 'with resource value' do
      let(:subjects) { ['Moomin', 'Snorkmaiden', 'Valleys--Moomin Valley'] }

      let(:agg) do
        a = build(:source_resource)
        a.subject.first.providedLabel = subjects.join(';')
        a
      end

      it 'splits values into resources of the same class' do
        expect(subject.enrich_value(agg.subject.first))
          .to contain_exactly(an_instance_of(agg.subject.first.class),
                              an_instance_of(agg.subject.first.class),
                              an_instance_of(agg.subject.first.class))
      end

      it 'populates providedLabel for new objects' do
        results = subject.enrich_value(agg.subject.first)
        expect(results.map(&:providedLabel).flatten)
          .to contain_exactly(*subjects)
      end

      it 'retains values from original value with first match' do
        results = subject.enrich_value(agg.subject.first)
        expect(results.first.rdf_subject).to eq agg.subject.first.rdf_subject
        expect(results.first.prefLabel).to eq agg.subject.first.prefLabel
      end

      context 'with unsplittable value' do
        let(:subjects) { ['Moomin'] }

        it 'keeps the original value set' do
          expect(subject.enrich_value(agg.subject.first).first)
            .to be_isomorphic_with agg.subject.first
        end
      end
    end
  end
end
