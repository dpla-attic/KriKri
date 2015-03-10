FactoryGirl.define do
  factory :krikri_activity, class: Krikri::Activity do
    agent 'Krikri::Harvesters::OAIHarvester'
    opts '{"uri": "http://example.org/endpoint"}'
  end

  factory :krikri_activity_with_long_opts, parent: :krikri_activity do
    opts '{"uri": "http://example.org/endpoint",' \
      '"oai": {"metadata_prefix": "mods", "set": ["SSDPLABrynMawr",' \
      '"SSDPLACornell","SSDPLAUCSD","SSDPLAWashington","SSDelwareAtlas",' \
      '"SSDelwareGeorge","SSDelwareHistoric","SSDelwareIncorporated1968",' \
      '"SSDelwareIncorporated1959"]}}'
  end

  factory :krikri_harvest_activity, parent: :krikri_activity do
    agent 'Krikri::Harvesters::OAIHarvester'
    opts '{"uri": "http://example.org/endpoint", ' \
    '"oai": {"metadata_prefix": "mods", "set": "set1"}}'
  end

  factory :krikri_mapping_activity, parent: :krikri_activity do
    agent 'Krikri::Mapper::Agent'
    opts({ name: 'test_map', generator_uri: 'http://example.org/agent/1' }
      .to_json)
  end
end
