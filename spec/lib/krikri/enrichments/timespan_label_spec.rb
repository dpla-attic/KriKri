require 'spec_helper'

describe Krikri::Enrichments::TimespanLabel do
  it_behaves_like 'a field enrichment'

  context 'with a non-timespan object' do
    it 'returns value' do
      val = RDF::Node.new
      expect(subject.enrich_value(val)).to be val
    end
  end

  context 'with timespan object' do
    let(:timespan) do
      build(:timespan, prefLabel: label, begin: begin_date, end: end_date)
    end

    let(:label)      { nil }
    let(:begin_date) { nil }
    let(:end_date)   { nil }

    context 'with no properties' do
      it 'does nothing' do
        statements = timespan.statements.to_a

        expect(subject.enrich_value(timespan).statements)
          .to contain_exactly(*statements)
      end
    end

    context 'with label' do
      let(:label) { '199x - 2018' }
      let(:begin_date) { Date.parse('1000-01-01') }
      let(:end_date)   { Date.parse('1001-01-01') }

      it 'does nothing' do
        expect(subject.enrich_value(timespan).prefLabel)
          .to contain_exactly(label)
      end
    end
    
    context 'with begin date' do
      let(:begin_date) { Date.parse('1000-01-01') }
      
      it 'assigns label to begin date' do
        expect(subject.enrich_value(timespan).prefLabel)
          .to contain_exactly(begin_date.to_s)
      end
    end

    context 'with end date' do
      let(:end_date) { Date.parse('1001-01-01') }
      
      it 'assigns label to begin date' do
        expect(subject.enrich_value(timespan).prefLabel)
          .to contain_exactly(end_date.to_s)
      end
    end

    context 'with begin and end dates' do
      let(:begin_date) { Date.parse('1000-01-01') }
      let(:end_date)   { Date.parse('1001-01-01') }
      
      it 'assigns label to begin date' do
        expect(subject.enrich_value(timespan).prefLabel)
          .to contain_exactly("#{begin_date}/#{end_date}")
      end
      
      context 'and dates are the same' do
        let(:begin_date) { Date.parse('1000-01-01') }
        let(:end_date)   { begin_date }

        it 'assigns label to just begin date' do
          expect(subject.enrich_value(timespan).prefLabel)
            .to contain_exactly(begin_date.to_s)
        end
      end
    end
  end
end
