# frozen_string_literal: true

class DayOff < ApplicationRecord
  belongs_to :user

  validates :start_time, :user_id, presence: true
  validates :end_time, date: { after_or_equal_to: :start_time }
  validate :check_days_taken, on: %i[create edit]
  scope :for_week, ->(date) { where('start_time >= ? AND end_time <= ?', date.beginning_of_week, date.end_of_week) }
  scope :for_day, ->(date) { where('? BETWEEN start_time AND end_time', date) }

  def off_dates
    (start_time.to_date..end_time.to_date).to_a
  end

  def check_days_taken
    return true unless taken_days.present?

    errors.add(:base, "Available days are [#{available_days.join(', ')}]. Sorry, other day(s) is/are taken.")
    false
  end

  def taken_days
    off_dates.select do |date|
      # Query other DayOff records that overlap with the current date
      overlapping_day_offs = DayOff.where('? BETWEEN start_time AND end_time', date)
                                   .where.not(id: self.id) # Exclude the current DayOff instance

      # Check if there are any records found, indicating the day is taken
      overlapping_day_offs.exists?
    end.sort
  end

  def available_days
    off_dates.reject do |date|
      available_days = DayOff.where('? BETWEEN start_time AND end_time', date)
                             .where.not(id: self.id) # Exclude the current DayOff instance

      available_days.exists?
    end.sort
  end

  def any_of_days_taken?
    taken_days.present?
  end

  def user_name
    user.name_and_last_name
  end
end
