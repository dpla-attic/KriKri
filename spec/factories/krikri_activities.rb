FactoryGirl.define do

  factory :krikri_activity, class: Krikri::Activity do
    agent 'Krikri::Harvesters::OAIHarvester'
    opts '{"uri": "http://example.org/endpoint", ' \
         '"oai": {"metadata_prefix": "mods", "set": "set1"}}'
  end

end