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
    morning_end = date.change(hour: 15).change(min: 0)
    start_time >= date.beginning_of_day && end_time <= morning_end
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

    # return true if taken_days.empty?

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

      is_morning_off_taken = false
      is_evening_off_taken = false

      overlapping_day_offs.select do |day_off|
        return true if day_off.all_day_off?(date)

        is_morning_off_taken = true if day_off.morning_off?(date)
        is_evening_off_taken = true if day_off.evening_off?(date)

        is_evening_off_taken && is_morning_off_taken
      end
      # Check if there are any records found, indicating the day is taken
      overlapping_day_offs.exists?
    end.sort
  end

  def available_days
    test = off_dates.reject do |date|
      available_days = DayOff.where('? BETWEEN start_time AND end_time', date)
                             .where.not(id:) # Exclude the current DayOff instance
      half_taken_days = taken_days

      is_morning_off_taken = false
      is_evening_off_taken = false
      test = available_days.merge(half_taken_days).reject do |day_off|
        return true if day_off.all_day_off?(date)

        is_morning_off_taken = true if day_off.morning_off?(date)
        is_evening_off_taken = true if day_off.evening_off?(date)

        is_evening_off_taken && is_morning_off_taken
      end
      test.present?
    end

    test.map do |datetime|
      day_offs = DayOff.where('? BETWEEN start_time AND end_time', datetime)
      day_offs.map do |day_off|
        day_off.morning_off?(datetime.to_date) ? "#{datetime.to_date} 3PM - 9PM" : "#{datetime.to_date} 8AM - 3PM"
      end
    end.flatten.sort
  end

  def any_of_days_taken?
    taken_days.present?
  end

  def user_name
    user.name_and_last_name
  end
end
