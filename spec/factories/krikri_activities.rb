FactoryGirl.define do
  factory :krikri_activity, class: Krikri::Activity do
    id 1
    agent 'Krikri::Harvesters::OAIHarvester'
    opts '{"uri": "http://example.org/endpoint"}'
  end

  factory :krikri_harvest_activity, parent: :krikri_activity do
    id 2
    agent 'Krikri::Harvesters::OAIHarvester'
    opts '{"uri": "http://example.org/endpoint", ' \
    '"oai": {"metadata_prefix": "mods", "set": "set1"}}'
  end

  factory :krikri_mapping_activity, parent: :krikri_activity do
    id 3
    agent 'Krikri::Mapper::Agent'
    opts(
      {
        name: 'test_map',
        generator_uri: (RDF::URI(Krikri::Settings['marmotta']['ldp']) /
          Krikri::Settings['prov']['activity'] / '2').to_s
      }.to_json
    )
  end

  factory :krikri_activity_with_long_opts, parent: :krikri_activity do
    id 4
    opts '{"uri": "http://example.org/endpoint",' \
      '"oai": {"metadata_prefix": "mods", "set": ["SSDPLABrynMawr",' \
      '"SSDPLACornell","SSDPLAUCSD","SSDPLAWashington","SSDelwareAtlas",' \
      '"SSDelwareGeorge","SSDelwareHistoric","SSDelwareIncorporated1968",' \
      '"SSDelwareIncorporated1959"]}}'
  end

  factory :krikri_enrichment_activity, parent: :krikri_activity do
    id 5
    agent 'Krikri::Enricher'
    opts(
      {
        generator_uri: 'http://localhost:8983/marmotta/ldp/activity/3',
        chain: {
          'Krikri::Enrichments::StripHtml' => {
            input_fields: [{sourceResource: :title}]
          }
        }
      }.to_json
    )
  end
end
