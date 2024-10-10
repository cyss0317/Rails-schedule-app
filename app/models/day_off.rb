# frozen_string_literal: true

class DayOff < ApplicationRecord
  belongs_to :user

  validates :start_time, :user_id, presence: true
  validates :end_time, date: { after_or_equal_to: :start_time }
  validate :check_days_taken, on: %i[create edit]

  scope :for_week, ->(date) { where('start_time >= ? AND end_time <= ?', date.beginning_of_week, date.end_of_week) }
  scope :for_day_filtered_by_date, lambda { |date|
                                     where("DATE(start_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Chicago') <= ? AND
      DATE(end_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Chicago') >= ?", date.to_date, date.to_date)
                                   } # catches the shifts with multiple days but not single day shift }
  scope :for_day_filtered_by_datetime, lambda { |start_time, end_time|
                                         where('start_time <= ? AND end_time >= ?', start_time, end_time)
                                       }
  scope :evening_off_available, lambda { |start_time, end_time|
                                  where('start_time < ? AND end_time > ?', start_time, end_time)
                                }

  scope :morning_day_offs, lambda { |date|
    tz = 'America/Chicago'
    morning_start = date.in_time_zone(tz).beginning_of_day
    morning_end = date.in_time_zone(tz).change(hour: 15)

    where('start_time >= ? AND end_time <= ?', morning_start, morning_end)
  }

  scope :evening_day_offs, lambda { |date|
    tz = 'America/Chicago'
    morning_end = date.in_time_zone(tz).change(hour: 15)
    evening_end = date.in_time_zone(tz).end_of_day

    where('start_time >= ? AND end_time <= ?', morning_end, evening_end)
  }
  scope :all_day_offs, lambda { |date|
    for_day_filtered_by_date(date).where.not(id: DayOff.morning_day_offs(date).select(:id)).where.not(id: DayOff.evening_day_offs(date).select(:id))
  }

  def off_dates
    (start_time.to_date..end_time.to_date).to_a
  end

  def off_time_info(date)
    which_shift_off = if start_time.to_date <= date.to_date && end_time.to_date >= date.to_date
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

  def off_time_class(date)
    if start_time.to_date <= date.to_date && end_time.to_date >= date.to_date
      if morning_off?(date)
        'morning-color'
      elsif evening_off?(date)
        'evening-color'
      else
        'all-color line-height-50'
      end
    else
      ''
    end
  end

  def morning_off?(date)
    morning_end = date.in_time_zone('America/Chicago').change(hour: 15).change(min: 0)
    start_time >= date.in_time_zone('America/Chicago').beginning_of_day && (end_time - 1.second) <= morning_end
  end

  def evening_off?(date)
    morning_end = date.in_time_zone('America/Chicago').change(hour: 15).change(min: 0)
    evening_end = date.in_time_zone('America/Chicago').end_of_day
    (start_time + 1.second) >= morning_end && end_time <= evening_end
  end

  def half_day_taken?(date)
    return false if all_day_off?(date)

    morning_off?(date) || evening_off?(date)
  end

  def all_day_off?(date)
    start_time.to_date <= date.to_date && end_time.to_date <= date.to_date && !morning_off?(date) && !evening_off?(date)
  end

  def check_days_taken
    return true unless any_of_days_taken?

    # return true unless DayOff.for_day_filtered_by_datetime(start_time, end_time).present?
    half_day_offs = taken_days.select { |date| half_day_taken?(date) && DayOff.morning_day_offs(date) }
    # check if any of half day offs is morning off, if yes, check if evening off availability with evenging_off_available scope
    if half_day_offs.present?
      evening_off_availability = half_day_offs.select { |date| DayOff.morning_day_offs(date).present? }
      return true if evening_off_availability
    end

    if available_days.empty?
      errors.add(:base, 'All dates are already taken')
    else
      errors.add(:base, "Available dates are [#{available_days.join(', ')}]. Sorry, other day(s) is/are taken.")
    end

    # allow creation of day off if the day is taken but the other half is available

    false
  end

  def taken_days
    off_dates.select do |date|
      # Query other DayOff records that overlap with the current date
      overlapping_day_offs = DayOff.for_day_filtered_by_date(date)
                                   .where.not(id:) # Exclude the current DayOff instance

      # Check if there are any records found, indicating the day is taken
      overlapping_day_offs.exists?
    end.sort
  end

  def available_days
    # Assume `off_dates` is an array of Date objects representing the range from `start_time` to `end_time`.
    available_all_days = off_dates - taken_days

    half_day_available_days = taken_days.select do |date|
      # day_offs_for_date = DayOff.where('? BETWEEN start_time AND end_time', date)
      #                           .where.not(id:)

      morning_off_taken = DayOff.morning_day_offs(date)
      evening_off_taken = DayOff.evening_day_offs(date)
      # Filter out all-day offs and returns days for where only one half is taken
      !DayOff.all_day_offs(date).present? && (morning_off_taken != evening_off_taken)
      # !DayOff.all_day_offs(date).present? && (morning_off_taken.count > 1 || evening_off_taken.count > 1)
    end
    # Combine and uniquify all and half-day available days
    (available_all_days + half_day_available_days).uniq.sort.map do |date|
      day_offs = DayOff.where(
        "DATE(start_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Chicago') <= ? AND
        DATE(end_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Chicago') >= ?", date, date
      )

      # half_day_offs = taken_days.select { |date| half_day_taken?(date) && DayOff.morning_day_offs(date) }
      # # check if any of half day offs is morning off, if yes, check if evening off availability with evenging_off_available scope
      # if half_day_offs.present?
      #   evening_off_availability = half_day_offs.select { |date| DayOff.morning_day_offs(date).count > 1 }
      #   return true if evening_off_availability
      # end
      # availability = check_days_taken
      DayOff.where('start_time <= ? AND end_time >= ?', start_time, end_time).count
      taken_days.select { |date| half_day_taken?(date) && DayOff.morning_day_offs(date) }
      taken_days.select { |date| half_day_taken?(date) && DayOff.evening_day_offs(date) }
      # return "" if availability

      if day_offs.any? { |day_off| day_off.morning_off?(date) }
        "#{date} 3PM - 9PM" # Evening available
      elsif day_offs.any? { |day_off| day_off.evening_off?(date) }
        "#{date} 8AM - 3PM" # Morning available
      else
        "#{date} All Day" # Whole day available
      end
    end
  end

  def any_of_days_taken?
    taken_days.present?
  end

  def user_name
    user.name_and_last_name
  end

  def my_day_off?(current_user)
    current_user.id == user.id
  end

  def been_passed?
    end_time < Time.now
  end
end
