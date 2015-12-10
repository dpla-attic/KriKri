require 'spec_helper'

describe Krikri::HarvestSource, type: :model do

  it 'is a HarvestSource' do
    expect(subject).to be_a Krikri::HarvestSource
  end

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:krikri_harvest_source)).to be_valid
    end

    it 'validates institution presence' do
      expect(build(:krikri_harvest_source, institution: nil)).not_to be_valid
    end

    it 'validates name presence' do
      expect(build(:krikri_harvest_source, name: nil)).not_to be_valid
    end

    it 'validates source_type presence' do
      expect(build(:krikri_harvest_source, source_type: nil)).not_to be_valid
    end

    it 'validates URI presence' do
      expect(build(:krikri_harvest_source, uri: nil)).not_to be_valid
    end

    it 'validates URI format' do
      expect(build(:krikri_harvest_source, uri: 'bogus')).not_to be_valid
    end
  end
end
