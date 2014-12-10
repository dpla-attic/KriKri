shared_context 'mapping dsl' do
  before do
    # dummy class
    class DummyMappingImplementation
      include Krikri::MappingDSL
    end
  end

  after do
    Object.send(:remove_const, 'DummyMappingImplementation')
  end

  let(:mapping_class) { DummyMappingImplementation }
  let(:mapping) { mapping_class.new }
  let(:value) { 'value' }
end
