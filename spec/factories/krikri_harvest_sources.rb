FactoryGirl.define do

  factory :krikri_harvest_source, class: Krikri::HarvestSource do
    name 'OAI feed'
    source_type 'OAI'
    metadata_schema 'MARC'
    uri 'http://www.example.com'
    opts '{"set": "set1"}'
    notes 'These are notes about the Krikri Sample Source.'
    association :institution, factory: :krikri_institution
  end

end
