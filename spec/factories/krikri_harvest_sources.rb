FactoryGirl.define do

  factory :krikri_harvest_sources, class: Krikri::HarvestSource do
    name 'OAI feed'
    source_type 'OAI'
    metadata_schema 'MARC'
    uri 'http://www.example.com'
    notes 'These are notes about the Krikri Sample Source.'
    association :institution, factory: :krikri_institutions
  end

end
