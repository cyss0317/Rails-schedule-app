class Meeting < ApplicationRecord
  scope :find_all_by_user_id, -> (user_id) { where(user_id: user_id) }

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
