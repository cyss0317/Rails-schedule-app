class Company < ApplicationRecord
  validates :name, presence: true

  has_many :locations
  has_many :users
end
