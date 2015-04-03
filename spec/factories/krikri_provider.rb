FactoryGirl.define do
  factory :krikri_provider, class: Krikri::Provider do
    label 'Moomin Valley Historical Society'
    rdf_subject 'MoominValleyHistoricalSociety'

    initialize_with { new(rdf_subject) }
  end
end
