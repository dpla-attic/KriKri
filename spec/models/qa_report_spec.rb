require 'spec_helper'

describe Krikri::QAReport do

  subject { described_class.new(:provider => provider.id.to_s) }

  let(:provider) do
    agent = build(:agent)
    agent.set_subject! 'http://example.org/moomin'
    agent
  end

  let(:solutions) do
    RDF::Query::Solutions.new(
      [RDF::Query::Solution.new(value: RDF::Literal('abc'),
                                aggregation: DPLA::MAP::Aggregation
                                  .new('too-ticki').to_term,
                                isShownAt: DPLA::MAP::WebResource
                                  .new('http://example.org/too-ticki').to_term),
       RDF::Query::Solution.new(value: RDF::Literal('abc'),
                                aggregation: DPLA::MAP::Aggregation
                                  .new('little-my').to_term,
                                isShownAt: DPLA::MAP::WebResource
                                  .new('http://example.org/little-my').to_term),
       RDF::Query::Solution.new(value: RDF::Literal('123'),
                                aggregation: DPLA::MAP::Aggregation
                                  .new('moomin-mama').to_term,
                                isShownAt: DPLA::MAP::WebResource
                                  .new('http://example.org/moomin-mama')
                                  .to_term)])
  end

  shared_context 'with multiple aggregations' do
    before do
      agg = build(:aggregation)
      agg.set_subject!('mummi123')
      agg.provider = provider
      agg.save
      agg2 = build(:aggregation)
      agg2.set_subject!('mummi223')
      agg2.provider = provider
      agg2.save
    end
  end

  describe '#provider' do
    it 'is set on initalization' do
      expect(subject.provider).to eq provider.rdf_subject.to_s
    end
  end

  describe '#build_provider' do
    it 'gives a provider' do
      expect(subject.build_provider).to be_a Krikri::Provider
    end

    it 'gives provider with correct uri' do
      expect(subject.build_provider.rdf_subject).to eq provider.rdf_subject
    end
  end


  describe '#generate_field_report!' do
    it 'populates report with hash' do
      subject.generate_field_report!
      expect(subject.field_report).to be_a Hash
    end

    it 'generates data for all fields'
  end

  describe '#generate_count_report!' do

    it 'populates report with hash' do
      subject.generate_count_report!
      expect(subject.count_report).to be_a Hash
    end

    it 'generates count data for all fields'
  end

  describe '#solutions_to_hash' do
    it 'gives empty result for empty solution set' do
      expect(subject.send(:solutions_to_hash, RDF::Query::Solutions.new([])))
        .to be_empty
    end

    it 'gives a hash for the solution set' do
      expect(subject.send(:solutions_to_hash, solutions)).to be_a Hash
    end

    it 'gives a hash with solution keys' do
      expect(subject.send(:solutions_to_hash, solutions).keys)
        .to contain_exactly(*solutions.bindings[:value].uniq)
    end

    it 'gives a hash with solution keys' do
      hash = subject.send(:solutions_to_hash, solutions)
      expect(hash['abc'].count).to eq 2
    end
  end
end
