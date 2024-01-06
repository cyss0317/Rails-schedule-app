# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  first_name             :string           not null
#  last_name              :string           not null
#  middle_name            :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  color                  :string
#  company_id             :integer
#  location_id            :integer
#  phone_number           :string
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :company
  belongs_to :location
  has_many :meetings, dependent: :destroy

  # before_action :authenticate_user!
  def full_name
    "#{first_name.capitalize} #{middle_name.capitalize} #{last_name.capitalize}"
  end

  def name_and_last_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def name_and_initials
    "#{first_name.capitalize} #{middle_name[0].capitalize}. #{last_name[0].capitalize}"
  end

  def time_zone
    Time.now.zone || 'UTC'
  end
end
