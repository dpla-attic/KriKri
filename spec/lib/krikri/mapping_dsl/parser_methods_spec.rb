require 'spec_helper'

describe Krikri::MappingDSL::ParserMethods do
  before do
    # dummy class
    class DummyParserImpl
      include Krikri::MappingDSL::ParserMethods
    end
  end

  after do
    Object.send(:remove_const, 'DummyParserImpl')
  end

  subject { DummyParserImpl.new }

  let(:record) { instance_double('Krikri::XmlParser') }
  let(:real) { Krikri::XmlParser.new(build(:oai_dc_record)) }

  describe '#record' do
    it 'returns a callable object' do
      expect(subject.record).to respond_to :call
    end

    it 'has arity of 1 (for parsed record)' do
      expect(subject.record.arity).to eq 1
    end

    it 'returns a RecordProxy' do
      expect(subject.record)
        .to be_a Krikri::MappingDSL::ParserMethods::RecordProxy
    end
  end

  describe '#local_name' do
    it 'calls local_name on the record' do
      expect(record).to receive_message_chain(:record, :local_name)
        .and_return('moomin')
      expect(subject.local_name.call(record)).to eq 'moomin'
    end
  end

  describe '#record_uri' do
    it 'calls local_name on the record' do
      expect(record).to receive_message_chain(:record, :rdf_subject)
        .and_return('http://example.org/moomin')
      expect(subject.record_uri.call(record)).to eq 'http://example.org/moomin'
    end
  end
end

describe Krikri::MappingDSL::ParserMethods::RecordProxy do
  subject { described_class.new([], klass) }
  let(:klass) { class_double(Krikri::Parser::ValueArray) }

  it 'has attributes' do
    expect(subject).to have_attributes(:value_class => klass, :call_chain => [])
  end

  describe '#dup' do
    let(:duped) { subject.dup }

    it 'shares call_chain content' do
      expect(duped.call_chain).to eq subject.call_chain
    end

    it 'has a different call_chain object' do
      expect(duped.call_chain).not_to be subject.call_chain
    end

    it 'shares a value class' do
      expect(duped.value_class).to eq subject.value_class
    end
  end

  describe '#call' do
    before do
      allow(klass).to receive(:build).with(record).and_return(value)
      allow(value).to receive(:values).and_return([:my_value])
    end

    subject { described_class.new(call_chain, klass) }
    let(:record) { double }
    let(:value) { double }

    let(:call_chain) do
      [{ :name => :my_method,
         :args => [:moomin, :snorkmaiden],
         :block => Proc.new {}
       },
       { :name => :second_method,
         :args => [:too_ticky],
         :block => nil
       }]
    end

    it 'calls chain' do
      call_chain.each do |spec|
        expect(value).to receive(spec[:name]).ordered
          .with(*spec[:args], &spec[:block]).and_return(value)
      end
      subject.call(record)
    end

    it 'casts result to values' do
      call_chain.each do |spec|
        allow(value).to receive(spec[:name]).and_return(value)
      end
      expect(subject.call(record)).to eq [:my_value]
    end
  end

  describe '#arity' do
    it 'returns arity for #call' do
      expect(subject.arity).to eq described_class.instance_method(:call).arity
    end
  end

  describe 'method calls' do
    it 'rejects calls for methods undefined on @value_class' do
      expect { subject.undefined_method }.to raise_error NoMethodError
    end

    it "knows it won't respond to undefined on @value_class" do
      expect(subject.respond_to?(:undefined_method)).to eq false
    end

    context 'when method exists' do
      before do
        allow(klass).to receive(:instance_methods).and_return([:field])
        allow(klass).to receive(:instance_method).with(:field)
          .and_return(instance_double(UnboundMethod, :arity => 1))
      end

      it "knows it will respond to the method" do
        expect(subject.respond_to?(:field)).to eq true
      end

      it 'raises an error when not matching arity' do
        expect { subject.field }.to raise_error ArgumentError
      end

      it 'adds method to call chain' do
        subject.field(:moomin).field(:valley) {}
        expect(subject.call_chain).to match([{ :name => :field,
                                               :args => [:moomin],
                                               :block => nil
                                             },
                                             { :name => :field,
                                               :args => [:valley],
                                               :block => an_instance_of(Proc)
                                             }])
      end

      it 'returns itself' do
        expect(subject.field(:moomin).field(:valley) {}).to eq subject
      end
    end
  end
end
