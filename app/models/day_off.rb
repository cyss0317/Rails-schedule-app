class DayOff < ApplicationRecord
  belongs_to :user

  validates :start_time, :user_id, presence: true
  validates :end_time, date: { after_or_equal_to: :start_time }
  validate :check_days_taken, on: :create

  def off_dates
    (start_time.to_date..end_time.to_date).to_a
  end

  def check_days_taken
    return true unless taken_days.present?

    errors.add(:full_messages, "These days are taken by others #{taken_days.join(', ')}")
    false
  end

  def taken_days
    off_dates.select do |date|
      # Query other DayOff records that overlap with the current date
      overlapping_day_offs = DayOff.where('? BETWEEN start_time AND end_time', date)
                                   .where.not(id:) # Exclude the current DayOff instance

      # Check if there are any records found, indicating the day is taken
      overlapping_day_offs.exists?
    end
  end

  def any_of_days_taken?
    taken_days.present?
  end
end
