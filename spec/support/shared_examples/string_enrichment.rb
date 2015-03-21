shared_examples 'a string enrichment' do |values|
  values.each do |value|
    it value[:string] do
      expect(subject.enrich_value(value[:start])).to eq value[:end]
    end
  end
end

shared_examples 'skips non-strings' do
  it 'skips non-string values' do
    date = Date.today
    expect(subject.enrich_value(date)).to eq date
  end
end

shared_examples 'deletes non-strings' do
  it 'deletes non-string values' do
    date = Date.today
    expect(Array(subject.enrich_value(date)).compact).to eq []
  end
end
