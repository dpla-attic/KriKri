FactoryGirl.define do
  factory :krikri_provider, class: Krikri::Provider do
    name 'Moomin Valley Historical Society'
    rdf_subject "#{Krikri::Provider.base_uri}123"
  end
end
