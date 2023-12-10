# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

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
