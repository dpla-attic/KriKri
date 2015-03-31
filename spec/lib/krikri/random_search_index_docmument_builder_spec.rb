require 'spec_helper'

describe Krikri::RandomSearchIndexDocumentBuilder do
  describe '#document' do
    context 'without provider id' do
      it 'returns nil with no record matches' do
        expect(subject.document).to be_nil
      end

      context 'with record' do
        include_context 'with indexed item'

        it 'gets a random document' do
          expect(subject.document).to be_a Krikri::SearchIndexDocument
        end
      end
    end

    context 'with provider id' do
      before { subject.provider_id = provider.id }

      context 'with record' do
        include_context 'with indexed item'

        it 'gets a random document' do
          expect(subject.document).to be_a Krikri::SearchIndexDocument
        end
      end
    end
  end
end
