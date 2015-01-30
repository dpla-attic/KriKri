shared_examples 'a string enrichment' do |values|
  it 'skips non-string values' do
    date = Date.today
    expect(subject.enrich_value(date)).to eq date
  end

  values.each do |value|
    it value[:string] do
      expect(subject.enrich_value(value[:start])).to eq value[:end]
    end
  end
end
