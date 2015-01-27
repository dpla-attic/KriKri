# -*- coding: utf-8 -*-
require 'spec_helper'

describe Krikri::Enrichments::IsoEnrich do
  it_behaves_like 'a field enrichment'

  let(:english) { RDF::URI('http://lexvo.org/id/iso639-3/eng') }
  let(:finnish) { RDF::URI('http://lexvo.org/id/iso639-3/fin') }

  shared_examples 'match finder' do |method, label|
    it 'returns a DPLA::MAP Language' do
      expect(subject.send(method, label))
        .to be_a DPLA::MAP::Controlled::Language
    end

    context 'with no matches' do
      it 'returns nil' do
        expect(subject.send(method, 'NOT A REAL LANG')).to be nil
      end
    end
  end

  context 'with string values' do
    it 'finds a uri value' do
      expect(subject.enrich_value('finnish'))
        .to have_attributes(:rdf_subject => finnish)
    end

    it 'sets providedLabel' do
      expect(subject.enrich_value('finnish'))
        .to have_attributes(:providedLabel => ['finnish'])
    end

    it 'gives nil for invalid values' do
      expect(subject.enrich_value('INVALID'))
        .to be nil
    end
  end

  context 'with a language resource' do
    let(:lang) { DPLA::MAP::Controlled::Language.new('eng') }

    it 'leaves the correct URI' do
      expect(subject.enrich_value(lang))
        .to have_attributes(:rdf_subject => english)
    end
  end

  context 'with node' do
    let(:lang) do
      lang = ActiveTriples::Resource.new
      lang << RDF::Statement(lang, RDF::DPLA.providedLabel, 'eng')
    end

    it 'enriches from providedLabel' do
      expect(subject.enrich_value(lang))
        .to contain_exactly(have_attributes(:rdf_subject => english))
    end

    it 'sets providedLabel' do
      expect(subject.enrich_value(lang))
        .to contain_exactly(have_attributes(:providedLabel => ['eng']))
    end

    context 'with no matching values' do
      before do
        lang.clear
        lang << RDF::Statement(lang, RDF::DPLA.providedLabel, 'moomin language')
      end

      it 'returns no values' do
        expect(subject.enrich_value(lang)).to be_empty
      end
    end

    context 'with multiple providedLabels' do
      context 'when labels match' do
        before do
          lang << RDF::Statement(lang, RDF::DPLA.providedLabel, 'eng')
          lang << RDF::Statement(lang, RDF::DPLA.providedLabel, 'english')
        end

        it 'squashes to a single value' do
          expect(subject.enrich_value(lang))
            .to contain_exactly(have_attributes(:rdf_subject => english))
        end
      end

      context 'when labels point to different resources' do
        before do
          lang << RDF::Statement(lang, RDF::DPLA.providedLabel, 'eng')
          lang << RDF::Statement(lang, RDF::DPLA.providedLabel, 'finnish')
          lang << RDF::Statement(lang, RDF::DPLA.providedLabel, 'NOT REAL')
        end

        it 'keeps both matches' do
          expect(subject.enrich_value(lang))
            .to contain_exactly(have_attributes(:rdf_subject => english),
                                have_attributes(:rdf_subject => finnish))
        end
      end
    end
  end

  describe '#match_iso' do
    include_examples 'match finder', :match_iso, 'eng'

    it 'finds URIs for 3 letter ISO codes' do
      expect(subject.match_iso('eng').rdf_subject)
        .to eq english
    end
  end

  describe '#match_label' do
    include_examples 'match finder', :match_label, 'finnish language'
    it 'finds URIs that match explicit labels from Lexvo' do
      expect(subject.match_label('finnish language').rdf_subject)
        .to eq finnish
    end
  end
end
