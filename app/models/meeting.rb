class Meeting < ApplicationRecord
  scope :find_all_by_user_id, ->(user_id) { where(user_id:) }

  def self.default
    where(start_time: Date.today.beginning_of_month.beginning_of_week..Date.today.end_of_month.end_of_week)
  end

  def user_name
    User.find(user_id).full_name
  end

  def user_name_month
    User.find(user_id).name_and_initials
  end

  # display work time from to end
  def work_time
    "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end
  belongs_to :user

  validates :name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :start_time_cannot_be_greater_than_end_time

  private

  def start_time_cannot_be_greater_than_end_time
    return unless start_time.present? && end_time.present?

    errors.add(:start_time, "can't be greater than end time") if start_time > end_time
  end
end