FactoryGirl.define do
  factory :krikri_activity, class: Krikri::Activity do
    agent 'Krikri::Harvesters::OAIHarvester'
    opts '{"uri": "http://example.org/endpoint"}'
  end

  factory :krikri_harvest_activity, parent: :krikri_activity do
    id 1
    agent 'Krikri::Harvesters::OAIHarvester'
    opts '{"uri": "http://example.org/endpoint", ' \
    '"oai": {"metadata_prefix": "mods", "set": "set1"}}'
  end

  factory :krikri_mapping_activity, parent: :krikri_activity do
    id 2
    agent 'Krikri::Mapper::Agent'
    opts(
      {
        name: 'test_map',
        generator_uri: 'http://localhost:8983/marmotta/ldp/activity/1'
      }.to_json
    )
  end

  # FIXME:
  #
  # The following `factory' will cause a FactoryGirl::InvalidFactoryError error
  # because "Krikri::Enrichments::StripHtml" fails the validation of the
  # Activity model, because it's not the name of a class that extends or
  # includes Krikri::SoftwareAgent.
  # (See Krikri::Activity#agent_must_be_a_software_agent)
  # 
  # e.g.:
  #
  # [4] pry(main)> Krikri::Mapper::Agent < Krikri::SoftwareAgent          
  # => true
  # [2] pry(main)> Krikri::Enrichments::StripHtml < Krikri::SoftwareAgent  
  # => nil
  # [7] pry(main)> Krikri::Enrichment < Krikri::SoftwareAgent
  # => nil
  # [9] pry(main)> Krikri::Mapper::Agent.include?(Krikri::SoftwareAgent)
  # => true
  # [10] pry(main)> Krikri::Enrichments::StripHtml.include?(Krikri::SoftwareAgent)
  # => false
  # [11] pry(main)> e = Krikri::Enrichments::StripHtml.new
  # => #<Krikri::Enrichments::StripHtml:0x007fa08ef3c100>
  # [12] pry(main)> e.respond_to?(:agent_name)
  # => false
  #
  # It's not clear from the inline enrichment comments how to enqueue
  # enrichments, and what agent class name should be saved in `activity.agent'
  #
  # factory :krikri_enrichment_activity, parent: :krikri_activity do
  #   id 3
  #   agent 'Krikri::Enrichments::StripHtml'
  #   opts(
  #     {
  #       name: 'test_foo',
  #       generator_uri: 'http://localhost:8983/marmotta/ldp/activity/2'
  #     }.to_json
  #   )
  # end
end
