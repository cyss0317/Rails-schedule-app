class LocationUser < ApplicationRecord
  belongs_to :user, inverse_of: :location_users
  belongs_to :location
  has_one :company, through: :location

  validates :user_id, uniqueness: { scope: :location_id }

  scope :filter_by_location_id, ->(location_id) { where(location_id:) }
end
