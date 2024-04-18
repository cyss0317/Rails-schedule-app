# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, presence: true, length: { maximum: 15 }
  validates :last_name, presence: true, length: { maximum: 15 }

  has_many :meetings, dependent: :destroy
  has_many :day_offs, dependent: :destroy

  scope :sort_by_first_name, -> { order(first_name: :asc) }
  scope :without_demo_user, lambda {
                              where('LOWER(first_name) NOT LIKE ?', '%demo%').where('LOWER(email) NOT LIKE ?', '%demo%')
                            }

  def full_name
    "#{first_name.capitalize} #{middle_name.capitalize} #{last_name.capitalize}"
  end

  def name_and_last_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def name_and_initials
    "#{first_name.capitalize} #{middle_name[0].capitalize if middle_name.present?}. #{last_name[0].capitalize}"
  end

  def time_zone
    Time.now.zone || 'UTC'
  end
end
