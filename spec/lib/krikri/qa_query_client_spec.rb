require 'spec_helper'

describe Krikri::QAQueryClient do
  let(:agg) do
    agg = build(:aggregation)
    agg.provider = provider
    agg.set_subject!('qa_query_aggregation')
    agg
  end

  let(:provider) do
    pro = build(:agent)
    pro.set_subject!('http://example.org/moomin')
    pro
  end

  let(:predicates) do
    [RDF::EDM.aggregatedCHO, RDF::DC.creator, RDF::SKOS.prefLabel]
  end

  shared_context 'with saved provider' do
    before { agg.save }
    after { Krikri::Repository.clear }
  end

  describe '#values_for_predicate' do
    it 'gives no solutions' do
      expect(subject.values_for_predicate(predicates, provider).execute)
        .to be_empty
    end

    context 'with matches' do
      include_context 'with saved provider'

      it 'gives solutions' do
        label = agg.sourceResource.first.creator.first.label.first
        expect(subject.values_for_predicate(predicates, provider).execute)
          .to contain_exactly an_instance_of RDF::Query::Solution

      end

      it 'gives solutions with values and aggregations' do
        label = agg.sourceResource.first.creator.first.label.first
        expect(subject.values_for_predicate(predicates, provider).execute.first)
          .to contain_exactly [:value, RDF::Literal.new(label)],
                              [:aggregation, agg.rdf_subject],
                              [:isShownAt, agg.isShownAt.first.rdf_subject]

      end

      context 'multiple matches' do
        let(:agg2) do
          a = build(:aggregation)
          a.set_subject! 'new_item'
          a.sourceResource.first.creator.first.label = 'moomin'
          a.provider = provider
          a
        end

        let(:agg3) do
          a = build(:aggregation)
          a.set_subject! 'new_item2'
          a.provider = provider
          a
        end

        before do
          agg2.save
          agg3.save
        end

        it 'gives solutions with values and aggregations' do
          expect(subject.values_for_predicate(predicates, provider)
                  .execute.map(&:to_h))
            .to contain_exactly({ value: RDF::Literal('moomin'),
                                  aggregation: agg2.to_term,
                                  isShownAt: agg2.isShownAt.first.to_term },
                                { value: RDF::Literal('Davies, Diana (1938-)'),
                                  aggregation: agg.to_term,
                                  isShownAt: agg.isShownAt.first.to_term },
                                { value: RDF::Literal('Davies, Diana (1938-)'),
                                  aggregation: agg3.to_term,
                                  isShownAt: agg3.isShownAt.first.to_term })
        end
      end
    end
  end

  describe '#counts_for_predicate' do
    it 'returns count of 0' do
      expect(subject.counts_for_predicate(predicates, provider).execute
              .first['count'].object).to eq 0
    end

    context 'with matches' do
      include_context 'with saved provider'

      it 'returns correct count' do
        expect(subject.counts_for_predicate(predicates, provider).execute
                .first[:count].object).to eq 1
      end

      it 'returns correct value' do
        expect(subject.counts_for_predicate(predicates, provider).execute
                .first[:value].object)
          .to eq agg.sourceResource.first.creator.first.label.first
      end
    end
  end

  describe '#build_optional_patterns' do
    it 'returns a list of patterns' do
      predicates = [RDF::DC.creator, RDF::OWL.sameAs, RDF.type]
      expect(subject.build_optional_patterns(predicates))
        .to contain_exactly [:aggregation, predicates.first, :obj0],
                            [:obj0, predicates[1], :obj1],
                            [:obj1, predicates[2], :value]
    end
  end
end
