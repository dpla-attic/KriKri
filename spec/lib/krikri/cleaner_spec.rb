require 'spec_helper'

describe Krikri::Cleaner do
  subject { described_class.new }

  it_behaves_like 'a software agent'

  describe '#initialize' do
    it do
      subject
    end
  end

  describe '#run' do
    before { allow(subject).to receive(:records).and_return(records) }
    let(:records) do
      [instance_double("DPLA::MAP::Aggregation"), 
       instance_double("DPLA::MAP::Aggregation")]
    end
    
    it 'invalidates the records' do
      records.each { |rec| expect(rec).to receive(:invalidate!) }
      subject.run
    end
  end
end
