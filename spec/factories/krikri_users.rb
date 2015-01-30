
FactoryGirl.define do
  factory :krikri_user, class: Krikri::User do
    email 'test@example.tld'
    password 'abcabcabc'
  end
end
