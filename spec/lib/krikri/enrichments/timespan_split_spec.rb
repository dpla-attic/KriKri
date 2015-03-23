require 'spec_helper'

describe Krikri::Enrichments::TimespanSplit do
  it_behaves_like 'a field enrichment'

  context 'with a non-timespan object' do
    it 'returns value' do
      val = RDF::Node.new
      expect(subject.enrich_value(val)).to be val
    end
  end

  context 'with string' do
    context 'ranged' do
      it "parses to timespan" do
        expect(subject.enrich_value('1993-1997')).to be_a DPLA::MAP::TimeSpan
      end

      it "sets begin on timespan" do
        expect(subject.enrich_value('1993-1997').begin)
          .to eql [Date.new(1993,1,1)]
      end

      it "sets end on timespan" do
        expect(subject.enrich_value('1993-1997').end)
          .to eql [Date.new(1997,12,31)]
      end
    end
  end

  context 'with timespan object' do
    let(:timespan) do
      build(:timespan, providedLabel: label, begin: begin_date, end: end_date)
    end

    let(:label) { nil }
    let(:begin_date) { nil }
    let(:end_date) { nil }

    context 'with label' do
      let(:label) { '199x - 2018' }

      it 'adds begin date' do
        expect(subject.enrich_value(timespan).begin)
          .to eql [Date.new(1990, 1, 1)]
      end

      it 'adds end date' do
        expect(subject.enrich_value(timespan).end)
          .to eql [Date.new(2018, 12, 31)]
      end

      context 'and begin date' do
        context 'earlier than parsed date' do
          let(:begin_date) { Date.parse('-0002-01-01') }

          it 'uses existing date' do
            expect(subject.enrich_value(timespan).begin).to eql [begin_date]
          end
        end

        context 'later than parsed date' do
          let(:begin_date) { Date.parse('5002-01-01') }

          it 'uses new date' do
            expect(subject.enrich_value(timespan).begin)
              .to eql [Date.new(1990, 1, 1)]
          end
        end
      end

      context 'and end date' do
        context 'earlier than parsed date' do
          let(:end_date) { Date.parse('-0002-01-01') }

          it 'uses new date' do
            expect(subject.enrich_value(timespan).end)
              .to eql [Date.new(2018, 12, 31)]
          end
        end

        context 'later than parsed date' do
          let(:end_date) { Date.parse('5002-01-01') }

          it 'uses existing date' do
            expect(subject.enrich_value(timespan).end).to eql [end_date]
          end
        end
      end

      context 'with precision' do
        let(:label) { '2019' }

        it 'sets begin to correct precision' do
          expect(subject.enrich_value(timespan).begin.first.to_s)
            .to eql Date.parse('2019-01-01').to_s
        end

        it 'sets end to correct precision' do
          expect(subject.enrich_value(timespan).end.first.to_s)
            .to eql Date.parse('2019-12-31').to_s

        end
      end
    end
  end
end
