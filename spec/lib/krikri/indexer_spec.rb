require 'spec_helper'

describe Krikri::Indexer do
  before(:all) do
    DatabaseCleaner.clean_with(:truncation)
    create(:krikri_enrichment_activity)
  end

  subject { described_class.new(opts) }

  enrichment_gen_uri_str = 'http://example.org/ldp/activity/5'
  behaves_opts = { generator_uri: enrichment_gen_uri_str,
                   index_class:   'Krikri::QASearchIndex' }

  it_behaves_like 'a software agent', behaves_opts
  
  # See mapper_agent_spec.rb regarding :opts and behaves_opts...
  let(:opts) do
    { generator_uri: enrichment_gen_uri_str,
      index_class:   index_class.to_s }
  end

  let(:index_class) { Krikri::QASearchIndex }

  describe '::queue_name' do
    it { expect(described_class.queue_name.to_s).to eq 'indexing' }
  end

  describe '#run' do
    let(:agg) { build(:aggregation) }   # :aggregation defined in DPLA::MAP
    let(:entity_enum) { Array.new(3, agg) }
    
    before do
      allow(subject.generator_activity).to receive(:entities)
        .and_return(entity_enum)
    end

    it 'indexes records' do
      expect(subject.index).to receive(:update_from_activity)
                                .with(subject.generator_activity)
      subject.run
    end
  end
end
