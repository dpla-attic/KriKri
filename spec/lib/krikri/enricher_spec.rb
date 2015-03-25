require 'spec_helper'

describe Krikri::Enricher do

  subject { described_class.new generator_uri: mapping_activity_uri }

  let(:mapping_activity_uri) do
    (RDF::URI(Krikri::Settings['marmotta']['ldp']) /
     Krikri::Settings['prov']['activity'] / '3').to_s
  end

  shared_context 'with enrichment chain' do
    subject do
      described_class.new generator_uri: mapping_activity_uri,
                          chain: chain
    end

    let(:chain) do
      {
        :'Krikri::Enrichments::StripHtml' => {
          input_fields: [{sourceResource: :title}]
        },
        :'Krikri::Enrichments::StripWhitespace' => {
          input_fields: [{sourceResource: :title}]
        }
      }
    end
  end

  describe '#initialize' do
    context 'with a chain argument that has been parsed from JSON' do
      # Activity records will contain the serialized chain hash, which is
      # passed in the call to Krikri::Enricher.enqueue.
      include_context 'with enrichment chain'

      subject do
        described_class.new generator_uri: mapping_activity_uri,
                            chain: JSON.parse(json_chain)
      end

      let(:json_chain) do
        <<-EOS.gsub /\s+/, ' '
        {
          "Krikri::Enrichments::StripHtml": {
            "input_fields":[{"sourceResource":"title"}]
          },
          "Krikri::Enrichments::StripWhitespace": {
            "input_fields":[{"sourceResource":"title"}]
          }
        }
EOS
      end

      it 'has a valid chain when it has been parsed from JSON' do
        expect(subject.chain).to eq(chain)
      end
    end
  end

  describe '#run' do
    let(:agg_double) { instance_double(DPLA::MAP::Aggregation) }
    let(:aggs) { [agg_double, agg_double.clone, agg_double.clone] }

    before do
      allow(subject).to receive(:target_aggregations)
                         .and_return(aggs)
    end

    context 'with errors thrown' do
      include_context 'with enrichment chain'

      before do
        aggs.each do |agg|
          allow(agg).to receive(:save).and_raise(StandardError.new)
        end
      end

      it 'logs errors' do
        expect(Krikri::SoftwareAgent::Logger)
          .to receive(:error)
          .with(start_with('Enrichment error'))
          .exactly(3).times

        subject.run
      end
    end

    it 'applies enrichment chain' do
      aggs.each do |agg|
        allow(agg).to receive(:save)
        expect(subject).to receive(:chain_enrichments!).with(agg)
      end
      subject.run
    end

    it 'saves resources' do
      aggs.each do |agg|
        expect(agg).to receive(:save)
      end
      subject.run
    end

    it 'saves resources with provenance' do
      activity_uri = RDF::URI 'http://example.org/enrich'
      aggs.each do |agg|
        expect(agg).to receive(:save_with_provenance).with(activity_uri)
      end
      subject.run(activity_uri)
    end
  end

  describe '#chain_enrichments!' do
    context 'with a chain of enrichments' do
      include_context 'with enrichment chain'
      let(:aggregation) { build(:aggregation) }

      before do
        # This title needs two enrichments applied, whitespace stripping and
        # HTML stripping.
        aggregation.sourceResource.first.title = ['<i>nice and clean</i> ']
      end

      it 'runs enrichments in the chain, on the generated aggregations' do
        subject.chain_enrichments!(aggregation)
        expect(aggregation.sourceResource.first.title)
          .to eq(['nice and clean'])
      end
    end

    context 'with a basic enrichment' do
      let(:chain) do
        {
          'Krikri::Enrichments::BasicEnrichment' => {
            input_fields: [{sourceResource: {creator: :providedLabel}}],
            output_fields: [{sourceResource: :creator}]
          }
        }
      end
      let(:aggregation) { build(:aggregation) }

      subject do
        described_class.new generator_uri: mapping_activity_uri, chain: chain
      end

      before do
        module Krikri::Enrichments
          class BasicEnrichment
            include Krikri::Enrichment
            def enrich_value(value)
              value
            end
          end
        end
      end

      it 'chains enrichments on basic fields' do
        expect { subject.chain_enrichments!(aggregation) }.to_not raise_error
      end
    end
  end
end
