class LocationUser < ApplicationRecord
  belongs_to :user
  belongs_to :location

  validates :user_id, uniqueness: { scope: :location_id }

  scope :filter_by_location_id, ->(location_id) { where(location_id:) }
end
