require 'spec_helper'

describe Krikri::RecordsHelper, :type => :helper do
  let(:document) { double }
  let(:agg) { build(:aggregation) }
  let(:original) { double }

  describe '#random_record_id' do
    it 'gives nil with no items' do
      expect(helper.random_record_id('abc')).to be_nil
    end

    context 'with indexed item' do
      include_context 'with indexed item'

      it 'gives a record local_name' do
        expect(helper.random_record_id(provider.id))
          .to eq helper.local_name(agg.rdf_subject)
      end
    end
  end

  describe '#render_enriched_record' do
    context 'with existing aggregation' do
      before(:each) do
        allow(document).to receive(:aggregation).and_return(agg)
      end

      it 'returns json String' do
        result = helper.render_enriched_record(document)
        expect { JSON.parse(result) }.not_to raise_error
      end
    end

    context 'without existing aggregation' do
      before(:each) do
        allow(document).to receive(:aggregation).and_return(nil)
      end

      it 'returns an error message' do
        expect(helper.render_enriched_record(document)).to be_a(String)
      end
    end

    describe '#render_original_record' do
      context 'with existing aggregation' do
        before(:each) do
          allow(document).to receive(:aggregation).and_return(agg)
        end

        context 'with original record' do
          before(:each) do
            allow(agg).to receive(:original_record).and_return(original)
          end

          context 'if content is json' do
            before(:each) do
              content = { 'a' => 'b' }.to_json
              allow(original).to receive(:to_s).and_return(content)
              allow(original).to receive(:content_type)
                .and_return('application/json')
            end

            it 'returns json String' do
              result = helper.render_original_record(document)
              expect { JSON.parse(result) }.not_to raise_error
            end
          end

          context 'if content is xml' do
            before(:each) do
              content = '<?xml version="1.0"?>hello</xml>'
              allow(original).to receive(:to_s).and_return(content)
              allow(original).to receive(:content_type).and_return('text/xml')
            end

            it 'renders String' do
              result = helper.render_original_record(document)
              expect(result).to be_a(String)
            end
          end

          context 'if content is String' do
            before(:each) do
              allow(original).to receive(:to_s).and_return('content string')
              allow(original).to receive(:content_type).and_return('text/plain')
            end

            it 'renders String' do
              result = helper.render_original_record(document)
              expect(result).to eq 'content string'
            end
          end
        end

        context 'without original record' do
          before(:each) do
            allow(agg).to receive(:original_record).and_return(nil)
          end

          it 'returns an error message' do
            expect(helper.render_original_record(document)).to be_a(String)
          end
        end
      end

      context 'without existing aggregation' do
        before(:each) do
          allow(document).to receive(:aggregation).and_return(nil)
        end

        it 'returns an error message' do
          expect(helper.render_original_record(document)).to be_a(String)
        end
      end
    end
  end
end
