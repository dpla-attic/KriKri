require 'spec_helper'

describe Krikri::HarvestSource, type: :model do

  let(:institution) { Krikri::Institution.create!(name: 'Test') }

  it 'is a HarvestSource' do
    expect(subject).to be_a Krikri::HarvestSource
  end

  it 'requires URIs to be well-formed' do
    baddata = {
      institution: institution,
      name: 'Test Source',
      source_type: 'OAI',
      metadata_schema: 'MODS',
      uri: 'bogus'
    }
    expect { Krikri::HarvestSource.create!(baddata) }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

end
