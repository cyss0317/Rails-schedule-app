class Location < ApplicationRecord
  belongs_to :company

  has_many :location_users
  has_many :users, through: :location_users
  has_many :meetings
end
