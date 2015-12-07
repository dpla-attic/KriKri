require 'spec_helper'

describe Krikri::EnrichmentProfile do
  it 'is an ActiveRecord' do
    expect(subject).to be_a ActiveRecord::Base
  end
end

describe Krikri::EnrichmentProfile::Enrichment do
  subject { described_class.new(enrichment) }
  
  let(:enrichment) { 'KlassName' }
  
  describe '#build' do
    it 'builds the enrichment' do
      subject.build
    end
  end

  describe 'valid?' do
    it { is_expected.not_to be_valid }

    context 'with class' do
      before { described_class.const_set(enrichment, new_klass) }

      let(:new_klass) { Class.new }

      it { is_expected.not_to be_valid }
      
      context 'as field enrichment' do
        let(:new_klass) do
          k = Class.new
          k.include Audumbla::FieldEnrichment
          k
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
