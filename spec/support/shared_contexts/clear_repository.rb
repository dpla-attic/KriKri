shared_context 'clear repository' do
  before do
    Krikri::Repository.clear!
  end

  after do
    Krikri::Repository.clear!
  end
end
