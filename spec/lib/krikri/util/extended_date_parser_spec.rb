require 'spec_helper'

describe Krikri::Util::ExtendedDateParser do
  subject { described_class }

  date_forms = [ '1992',
                 '1992-12-01',
                 '1992-12',
                 '12-1992',
                 '12-01-1992',
                 '12.01.1992',
                 '12/01/1992',
                 # '01/01/199u', # this isn't valid EDTF and returns a bad date
                 # '1992-11-uu?', # ETDF.rb doesn't support uu~
                 '1992-12-01?',
                 # '1992-11-uu~', # ETDF.rb doesn't support uu?
                 '1992-12-01~',
                 '1992-12-uu',
                 '1992.12.01',
                 '1992-12-01',
                 '1992.12',
                 '1992?',
                 '199x',
                 '1990s',
                 '199-',
                 'Dec 1992', # currently returns December 1
                 'Dec 01 1992',
                 'Dec 01, 1992'
               ]

  ranges = [ '-', 'to', 'until', '.', '......']

  describe '#parse' do
    date_forms.each do |str|
      it "parses #{str} to timespan" do
        result = subject.parse(str)
        if result.is_a? EDTF::Decade
          expect(result).to eq Date.edtf('199x')
        else
          expect(result).to eq Date.edtf('1992-12-01')
            .send("#{result.precision}_precision".to_sym)
        end
      end
    end
  end

  # describe '#range_match' do
  #   ranges.each do |delim|
  #     date_forms.each do |first|
  #       date_forms.each do |last|
  #         str = "#{first}  #{delim}  #{last}"
  #         it "parses #{str} to start/end array" do
  #           match = subject.range_match(str)
  #           expect(match.length).to eq 2
  #           expect(match.first).to include '199'
  #           expect(match[1]).to include '199'
  #           expect(subject.parse(match.first)).not_to be nil
  #           expect(subject.parse(match[1])).not_to be nil
  #         end
  #       end
  #     end
  #   end
  # end

  describe '#partial_edtf' do
    context 'with YYYY-MM-DD/DD' do
      let(:start_date) { Date.new(2014,1,27) }
      let(:end_date) { Date.new(2014,1,28) }

      it 'parses date' do
        expect(subject.partial_edtf('2014-01-27/28'))
          .to have_attributes(:from => start_date,:to => end_date)
      end

      it 'gives nil for invalid date' do
        expect(subject.partial_edtf('2014-01-98/28')).to eq nil
      end
    end

    context 'with YYYY-MM/MM' do
      let(:start_date) { Date.new(2014,1,1) }
      let(:end_date) { Date.new(2014,3,1) }

      it 'parses date' do
        expect(subject.partial_edtf('2014-01/03'))
          .to have_attributes(:from => start_date,:to => end_date)
      end

      it 'gives nil for invalid date' do
        expect(subject.partial_edtf('2014-33/03')).to eq nil
      end
    end
  end

  describe '#month_year' do
    let(:date) { Date.new(2014,2,1) }

    it 'parses date' do
      expect(subject.month_year('02-2014'))
        .to eql date
    end

    it 'parses date' do
      expect(subject.month_year('02-2014').precision)
        .to eq :month
    end
  end

  describe '#hyphenated_partial_range' do
    let(:start_date) { Date.new(2013,1,1) }
    let(:end_date) { Date.new(2014,1,1) }

    it 'parses date' do
      expect(subject.hyphenated_partial_range('2013-14'))
        .to have_attributes(:from => start_date,:to => end_date)
    end
  end

  describe '#decade_s' do
    it 'parses date' do
      expect(subject.decade_s('1990s'))
        .to eq Date.edtf('199x')
    end
  end

  describe '#decade_hyphen' do
    it 'parses date' do
      expect(subject.decade_hyphen('199-'))
        .to eq Date.edtf('199x')
    end
  end
end
