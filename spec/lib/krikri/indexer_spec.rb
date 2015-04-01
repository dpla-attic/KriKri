require 'spec_helper'

describe Krikri::Indexer do
  before(:all) do
    DatabaseCleaner.clean_with(:truncation)
    create(:krikri_enrichment_activity)
  end

  enrichment_gen_uri_str = 'http://example.org/ldp/activity/5'

  # See mapper_agent_spec.rb regarding :opts and behaves_opts...
  let(:opts) do
    {
      generator_uri: enrichment_gen_uri_str,
      index_class: 'Krikri::QASearchIndex'
    }
  end
  behaves_opts = {
    generator_uri: enrichment_gen_uri_str,
    index_class: 'Krikri::QASearchIndex'
  }

  it_behaves_like 'a software agent', behaves_opts

  subject { described_class.new(opts) }

  describe '::queue_name' do
    it { expect(described_class.queue_name.to_s).to eq 'indexing' }
  end

  describe '#run' do
    let(:agg) { build(:aggregation) }   # :aggregation defined in DPLA::MAP
    let(:entity_enum) do
      (1..50).lazy.map do |e|
        record = agg
        e.yield record
      end
    end
    before do
      allow(subject.generator_activity).to receive(:entities)
        .and_return(entity_enum)
    end

    it 'indexes records' do
      subject.run
    end
  end
end
