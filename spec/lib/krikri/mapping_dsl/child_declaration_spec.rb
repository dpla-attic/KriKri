describe Krikri::MappingDSL::ChildDeclaration do
  include_context 'mapping dsl'
  it_behaves_like 'a named property'
  subject { described_class.new(:my_property, klass) {} }
  let(:klass) { double }

  describe '#to_proc' do
    let(:mapping) { double }
    let(:target) { double }

    before do
      allow(::Krikri::Mapping).to receive(:new).and_return(mapping)
      allow(mapping).to receive(:process_record).with('').and_return(:value)
    end

    it 'returns a proc' do
      expect(target).to receive(:my_property=).with(:value)
      subject.to_proc.call(target, '')
    end
  end
end
