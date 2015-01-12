require 'spec_helper'

describe Krikri::ProvenanceQueryClient do
  before do
    Krikri::Repository.clear!
  end

  after do
    Krikri::Repository.clear!
  end

  let(:activity) { create(:krikri_activity) }
  let(:activity_uri) { activity.rdf_subject }

  shared_context 'with matching subjects' do
    before { record.save(activity_uri) }
    let(:record) { build(:krikri_original_record) }
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
