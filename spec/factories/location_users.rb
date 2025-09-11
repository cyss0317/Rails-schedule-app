FactoryBot.define do
  factory :location_user do
    role { %w[admin user].sample }
    association :user
    association :company
  end
end
