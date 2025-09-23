class Location < ApplicationRecord
  belongs_to :company

  has_many :location_users
  has_many :users, through: :location_users
  has_many :meetings
  has_many :day_offs

  def full_address
    [street_address, building_number, city, state, zip_code]
      .reject(&:blank?)
      .join(', ')
  end
end
