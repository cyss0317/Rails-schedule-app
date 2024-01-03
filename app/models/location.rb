class Location < ApplicationRecord
  validates :name, :address, :phone_number, :company_id, presence: true

  belongs_to :company
  has_many :users

  scope :by_company, ->(company_name) { joins(:company).where(companies: { name: company_name }) }
end
