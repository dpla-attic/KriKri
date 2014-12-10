shared_examples 'a named property' do
  it 'has name' do
    expect(subject.name).to eq :my_property
  end
end

shared_examples 'a valued property' do
  it 'has value' do
    expect(subject.value).to eq value
  end
end
