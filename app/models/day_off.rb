# frozen_string_literal: true

class DayOff < ApplicationRecord
  belongs_to :user

  validates :start_time, :user_id, presence: true
  validates :end_time, date: { after_or_equal_to: :start_time }
  validate :check_days_taken, on: %i[create edit]
  scope :for_week, ->(date) { where('start_time >= ? AND end_time <= ?', date.beginning_of_week, date.end_of_week) }
  scope :for_day_filtered_by_date, lambda { |date|
    where("DATE(start_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Chicago') <= ? AND
      DATE(end_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Chicago') >= ?", date.to_date, date.to_date) # catches the shifts with multiple days but not single day shift

    # where('DATE(start_time) <= ? AND end_time >= ?', date, date.end_of_day.change(sec: 0)) # catches the shifts with multiple days but not single day shift
    # where('start_time <= ? AND end_time >= ?', date.to_date, date.to_date) # catches the shifts with multiple days but not single day shift
  }
  scope :for_day_filtered_by_datetime, lambda { |datetime|
    where('start_time <= ? AND end_time >= ?', datetime, datetime)
  }
  scope :morning_day_offs, lambda { |date|
                             for_day_filtered_by_date(date).where('start_time <= ? AND end_time >= ?', date.change(hour: 8), date.change(hour: 15))
                           }
  scope :evening_day_offs, lambda { |date|
                             for_day_filtered_by_date(date).where('start_time <= ? AND end_time <= ?', date.change(hour: 15), date.end_of_day)
                           }
  def off_dates
    (start_time.to_datetime..end_time.to_datetime).to_a
  end

  def off_time_info(date)
    which_shift_off = if start_time.to_date == date.to_date && end_time.to_date == date.to_date
                        if morning_off?(date)
                          'Morning'
                        elsif evening_off?(date)
                          'Evening'
                        else
                          'All Day'
                        end
                      else
                        'No Day Off'
                      end
    "#{user.first_name}, #{which_shift_off} Off"
  end

  def morning_off?(date)
    morning_start = date.change(hour: 8).change(min: 0)
    morning_end = date.change(hour: 15).change(min: 0)
    start_time >= morning_start && end_time <= morning_end
  end

  def evening_off?(date)
    morning_end = date.change(hour: 15).change(min: 0)
    evening_end = date.end_of_day
    start_time >= morning_end && end_time <= evening_end
  end

  def all_day_off?(date)
    start_time.to_date == date.to_date && end_time.to_date == date.to_date && !morning_off?(date) && !evening_off?(date)
  end

  def check_days_taken
    return true unless taken_days.present?

    if available_days.empty?
      errors.add(:base, 'All dates are already taken')
    else
      errors.add(:base, "Available dates are [#{available_days.join(', ')}]. Sorry, other day(s) is/are taken.")
    end

    false
  end

  def taken_days
    off_dates.select do |date|
      # Query other DayOff records that overlap with the current date
      overlapping_day_offs = DayOff.where('? BETWEEN start_time AND end_time', date)
                                   .where.not(id:) # Exclude the current DayOff instance

      # Check if there are any records found, indicating the day is taken
      overlapping_day_offs.exists?
    end.sort
  end

  def available_days
    off_dates.reject do |date|
      available_days = DayOff.where('? BETWEEN start_time AND end_time', date)
                             .where.not(id:) # Exclude the current DayOff instance

      available_days.exists?
    end.map(&:to_date).sort
  end

  def any_of_days_taken?
    taken_days.present?
  end

  def user_name
    user.name_and_last_name
  end
end
