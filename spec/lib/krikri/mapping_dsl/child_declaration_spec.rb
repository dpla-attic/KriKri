describe Krikri::MappingDSL::ChildDeclaration do
  include_context 'mapping dsl'
  it_behaves_like 'a named property'
  subject { described_class.new(:my_property, klass) {} }
  let(:klass) { double }

  let(:target) { double }
  let(:mapping) { double }

  before do
    allow(::Krikri::Mapping).to receive(:new).and_return(mapping)
  end

  describe '#to_proc' do
    before do
      allow(mapping).to receive(:process_record).with('').and_return(:value)
    end

    it 'sets value of property to result of process_record' do
      expect(target).to receive(:my_property=).with(:value)
      subject.to_proc.call(target, '')
    end
  end

  context 'with each/as declarations' do
    subject { described_class.new(:my_property, klass, opts) {  } }
    let(:opts) { { :each => record_proxy, :as => :my_val } }
    let(:record_proxy) { double }
    let(:record_proxy_dup) { double }
    let(:values) { [:a, :b, :c] }

    before do
      allow(target).to receive(:my_property).and_return(double)
      allow(record_proxy).to receive(:call).and_return(values)
      allow(record_proxy).to receive(:dup).and_return(record_proxy_dup)
      allow(record_proxy_dup).to receive(:select).and_return(values.first)
      allow(mapping).to receive(:process_record).with('').and_return(values.first)
    end

    it 'sets values of property to results of process_record' do
      expect(target.my_property).to receive(:<<).with(values.first)
        .exactly(3).times
      subject.to_proc.call(target, '')
    end

    it 'defines DSL method for access to individual value' do
      allow(target.my_property).to receive(:<<).with(values.first)
      subject.to_proc.call(target, '')
      expect(mapping.my_val).to eq values.first
    end
  end
end
