# -*- coding: utf-8 -*-
require 'spec_helper'

describe Krikri::Enrichments::LanguageToLexvo do
  it_behaves_like 'a field enrichment'

  let(:english) { RDF::URI('http://lexvo.org/id/iso639-3/eng') }
  let(:finnish) { RDF::URI('http://lexvo.org/id/iso639-3/fin') }

  shared_examples 'match finder' do |method, label|
    it 'returns a DPLA::MAP Language' do
      expect(subject.send(method, label))
        .to be_a DPLA::MAP::Controlled::Language
    end

    context 'with no matches' do
      it 'returns a node' do
        expect(subject.send(method, 'NOT A REAL LANG')).to be_node
      end
    end
  end

  context 'with string values' do
    it 'finds a uri value' do
      expect(subject.enrich_value('finnish'))
        .to be_exact_match_with finnish
    end

    it 'copies string to providedLabel' do
      expect(subject.enrich_value('finnish'))
        .to have_provided_label('finnish')
    end

    it 'gives a bnode' do
      expect(subject.enrich_value('finnish')).to be_node
    end

    it 'adds a prefLabel' do
      expect(subject.enrich_value('finnish').prefLabel)
        .to contain_exactly 'Finnish'
    end

    context 'and no match' do
      it 'gives a language' do
        expect(subject.enrich_value('INVALID'))
          .to be_a DPLA::MAP::Controlled::Language
      end

      it 'gives a bnode' do
        expect(subject.enrich_value('INVALID')).to be_node
      end

      it 'sets providedLabel to input value' do
        expect(subject.enrich_value('INVALID'))
          .to have_provided_label('INVALID')
      end
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
        .to contain_exactly(be_exact_match_with(english))
    end

    context 'with no matching values' do
      before do
        lang.clear
        lang << RDF::Statement(lang, RDF::DPLA.providedLabel, label)
      end

      let(:label) { 'moomin language' }

      it 'returns a node' do
        expect(subject.enrich_value(lang).first)
          .to be_a DPLA::MAP::Controlled::Language
      end

      it 'gives same providedLabel' do
        expect(subject.enrich_value(lang).first)
          .to have_provided_label(label)
      end
    end

    context 'with multiple providedLabels' do
      context 'when labels point to same resource match' do
        before do
          lang << RDF::Statement(lang, RDF::DPLA.providedLabel, 'eng')
          lang << RDF::Statement(lang, RDF::DPLA.providedLabel, 'english')
        end

        it 'matches both values' do
          expect(subject.enrich_value(lang))
            .to contain_exactly(be_exact_match_with(english),
                                 be_exact_match_with(english))
        end

        it 'keeps both provided labels' do
          expect(subject.enrich_value(lang))
            .to contain_exactly(have_provided_label('eng'),
                                have_provided_label('english'))


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
            .to contain_exactly(be_exact_match_with(english),
                                be_exact_match_with(finnish),
                                have_provided_label('NOT REAL'))
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
