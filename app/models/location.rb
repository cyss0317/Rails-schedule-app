# == Schema Information
#
# Table name: locations
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  address      :string           not null
#  phone_number :string           not null
#  ip_address   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer
#
class Location < ApplicationRecord
  validates :name, :address, :phone_number, :company_id, presence: true

  belongs_to :company
  has_many :users

  scope :by_company, ->(company_name) { joins(:company).where(companies: { name: company_name }) }
end
