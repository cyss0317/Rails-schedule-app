# frozen_string_literal: true

# == Schema Information
#
# Table name: meetings
#
#  id         :bigint           not null, primary key
#  name       :string
#  start_time :datetime
#  end_time   :datetime
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  start_date :datetime
#  time       :time
#
FactoryBot.define do
  factory :meeting do
    name { 'MyString' }
    start_time { '2023-11-17 23:56:19' }
    end_time { '2023-11-17 23:56:19' }
    user_id { 1 }
  end
end
