require 'spec_helper'

describe Krikri::Enrichments::DcmiTypeMap do
  it_behaves_like 'a field enrichment'

  shared_examples 'with match' do |str, expected_match|
    it 'finds match' do
      expect(subject.enrich_value(str).rdf_subject)
        .to eq expected_match
    end
  end

  it 'populates prefLabel' do
    expect(subject.enrich_value('Image').prefLabel)
      .to contain_exactly RDF::DCMITYPE.Image.label
  end

  context 'with exact match' do
    include_examples 'with match', 'Image', RDF::DCMITYPE.Image
  end

  context 'with case insensitive match' do
    include_examples 'with match', 'imagE', RDF::DCMITYPE.Image
  end

  context 'with fuzzy match' do
    include_examples 'with match', 'oral recording', RDF::DCMITYPE.Sound
    include_examples 'with match', 'journalism', RDF::DCMITYPE.Text
    include_examples 'with match', 'a written record', RDF::DCMITYPE.Text
    include_examples 'with match',
                     'physical object',
                     RDF::DCMITYPE.PhysicalObject
  end

  context 'with unmatched strings' do
    it 'gives nil' do
      expect(subject.enrich_value('this is totally not a type value')).to be_nil
    end
  end
end
