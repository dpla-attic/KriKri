require 'spec_helper'

describe Krikri::Enricher do

  subject do
    described_class.new generator_uri: mapping_activity_uri,
                        chain: chain
  end

  shared_context 'common' do
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
    let(:mapping_activity_uri) do
      (RDF::URI(Krikri::Settings['marmotta']['ldp']) /
        Krikri::Settings['prov']['activity'] / '3').to_s
    end
  end

  describe '#initialize' do
    context 'with a chain argument that has been parsed from JSON' do
      # Activity records will contain the serialized chain hash, which is
      # passed in the call to Krikri::Enricher.enqueue.
      include_context 'common'

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

    context 'with errors thrown' do
      include_context 'common'

      before do
        aggs.each do |agg|
          allow(agg).to receive(:save).and_raise(StandardError.new)
        end

        allow(subject).to receive(:target_aggregations)
                                    .and_return(aggs)
      end

      it 'logs errors' do
        expect(Krikri::SoftwareAgent::Logger)
          .to receive(:error)
          .with(start_with('Enrichment error'))
          .exactly(3).times

        subject.run
      end
    end
  end

  describe '#chain_enrichments!' do
    context 'with a chain of enrichments' do
      include_context 'common'
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
  end

end
