FactoryGirl.define do

  factory :krikri_activity, class: Krikri::Activity do
    agent 'Krikri::Harvesters::OAIHarvester'
    opts '{"endpoint": "http://example.org/endpoint", ' \
         ' "metadata_prefix": "mods"}'
  end

end