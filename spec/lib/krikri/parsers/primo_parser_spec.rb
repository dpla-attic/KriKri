require 'spec_helper'

describe Krikri::PrimoParser do
  subject { Krikri::PrimoParser.new(record) }
  let(:record) { build(:primo_record) }

  it 'provides some useful helpers for navigating nested records' do
    expect(Krikri::PrimoParser.search('lsr13')).to eq(['nmbib:PrimoNMBib',
                                                       'nmbib:record',
                                                       'nmbib:search',
                                                       'nmbib:lsr13'])

    expect(Krikri::PrimoParser.display('creator')).to eq(['nmbib:PrimoNMBib',
                                                          'nmbib:record',
                                                          'nmbib:display',
                                                          'nmbib:creator'])

    expect(Krikri::PrimoParser.record('top')).to eq(['nmbib:PrimoNMBib',
                                                     'nmbib:record',
                                                     'nmbib:top'])
  end

  it_behaves_like 'a parser'
end
