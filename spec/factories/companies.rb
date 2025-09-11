FactoryBot.define do
  factory :company do
    association :user
    name { Faker::Company.company_name }
  end
end
