require 'spec_helper'

describe Krikri::ProvenanceQueryClient do
  before { Krikri::Repository.clear! }
  after  { Krikri::Repository.clear! }

  let(:activity)     { create(:krikri_activity) }
  let(:activity_uri) { activity.rdf_subject }

  let(:not_exists_condition) do
    'NOT EXISTS { ?record <http://www.w3.org/ns/prov#invalidatedAtTime> ?x }'
  end

  shared_context 'with matching subjects' do
    before       { record.save(activity_uri) }
    let(:record) { build(:krikri_original_record) }
  end

  describe '#count_by_activity' do
    it 'returns a zero count' do
      expect(subject.count_by_activity(activity_uri)).to eq 0
    end

    context 'with matching subjects' do
      include_context 'with matching subjects'

      xit 'returns a correct count' do
        expect(subject.count_by_activity(activity_uri)).to eq 1
      end
    end
  end

  describe '#add_invalidated_filter' do
    it 'adds a filter on :record to an arbitrary query' do
      query = SPARQL::Client::Query.select.where([:s, :p, :o])
      expect(subject.add_invalidated_filter(query).to_s)
        .to include not_exists_condition
    end
  end

  describe '#find_by_activity' do
    it 'raises an argument error for non-uris' do
      expect { subject.find_by_activity(activity_uri.to_s) }
        .to raise_error ArgumentError
    end

    it 'returns a query object' do
      expect(subject.find_by_activity(activity_uri))
        .to be_a SPARQL::Client::Query
    end

    context 'without optional arguments' do
      it 'defaults to excluding invalidated records' do
        expect(subject.find_by_activity(activity_uri).to_s)
          .to include(not_exists_condition)
      end
    end

    context 'when optional include_invalidated is true' do
      it 'includes invalidated records' do
        expect(subject.find_by_activity(activity_uri, true).to_s)
          .not_to include(not_exists_condition)
      end
    end

    context 'without matching subjects' do
      it 'is empty' do
        expect(subject.find_by_activity(activity_uri).solutions).to be_empty
      end
    end

    context 'with matching subjects' do
      include_context 'with matching subjects'

      it 'finds matching records' do
        expect(subject.find_by_activity(activity_uri).solutions.map(&:record))
          .to include record.rdf_source.rdf_subject
      end
    end
  end
end
