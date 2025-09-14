FactoryBot.define do
  factory :location_user do
    transient { meetings_count { 2 }}
    role { %w[admin user].sample }
    association :user
    association :location

    trait(:with_relationships) do
      after(:create) { |location_user, e| create_list(:meeting, e.meeting_count, user_id: location_user.user.id)}
    end
  end
end
