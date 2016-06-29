describe Krikri::MappingDSL::ChildDeclaration do
  include_context 'mapping dsl'
  it_behaves_like 'a named property'
  subject { described_class.new(:my_property, klass) {} }

  let(:klass)   { double('class') }
  let(:target)  { double('target') }
  let(:record)  { double('record') }
  let(:mapping) { instance_double('Krikri::Mapping') }

  before { allow(::Krikri::Mapping).to receive(:new).and_return(mapping) }

  describe '#to_proc' do
    before do
      allow(mapping).to receive(:process_record).with(record).and_return(value)
    end

    let(:value) { double('value') }

    it 'sets value of property to result of process_record' do
      expect(target).to receive(:my_property=).with(value)
      subject.to_proc.call(target, record)
    end
  end

  context 'with each/as declarations' do
    subject { described_class.new(:my_property, klass, opts) {} }

    let(:opts)         { { :each => record_proxy, :as => :my_val } }
    let(:values)       { [:a, :b, :c] }
    let(:record_proxy) { double('record proxy') }

    before do
      allow(target).to receive(:my_property).and_return(double)
      allow(record_proxy).to receive(:call).and_return(values)

      allow(mapping).to receive(:process_record).with(record)
        .and_return(*values)
    end

    it 'sets values of property to results of process_record' do
      values.each { |v| expect(target.my_property).to receive(:<<).with(v) }
      subject.to_proc.call(target, record)
    end

    it 'defines DSL method for access to individual value in mapping scope' do
      values.each { |v| allow(target.my_property).to receive(:<<).with(v) }

      subject.to_proc.call(target, record)
      expect(mapping.my_val).to eq values.last
    end
  end
end
