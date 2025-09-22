FactoryBot.define do
  factory :location_user do
    user
    location
    transient { meetings_count { 2 }}
    role { %w[admin user].sample }

    trait(:with_relationships) do
      association :user
      association :location
      after(:create) { |location_user, e| create_list(:meeting, e.meeting_count, user_id: location_user.user.id)}
    end
  end
end
