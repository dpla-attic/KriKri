RSpec::Matchers.define :be_exact_match_with do |expected|
  match do |actual|
    not actual.first([actual, RDF::SKOS.exactMatch, expected]).nil?
  end
end

RSpec::Matchers.define :have_provided_label do |expected|
  match do |actual|
    pattern = [actual, RDF::DPLA.providedLabel, nil]
    expect(actual.query(pattern).map(&:object)).to include(expected)
    true
  end
end

