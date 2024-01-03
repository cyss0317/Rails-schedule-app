class Location < ApplicationRecord
  validates :name, :address, :phone_number, presence: true

  has_many :users
end