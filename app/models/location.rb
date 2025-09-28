class Location < ApplicationRecord
  belongs_to :company

  has_many :location_users
  has_many :users, through: :location_users
  has_many :meetings
  has_many :day_offs

  def full_address
    a = [street_address, building_number].reject(&:blank?).join(' ')
    b = [city].reject(&:blank?).join('')
    c = [state, zip_code].reject(&:blank?).join(' ')

    [a, b, c].join(', ')
  end
end
