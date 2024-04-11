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
  scope :all_day_offs, lambda { |date|
    for_day_filtered_by_date(date).where('start_time <= ? AND end_time >= ?', date.beginning_of_day, date.end_of_day)
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

  def morning_off?(date)
    morning_end = date.in_time_zone('America/Chicago').change(hour: 15).change(min: 0)
    start_time >= date.in_time_zone('America/Chicago').beginning_of_day && end_time <= morning_end
  end

  def evening_off?(date)
    morning_end = date.in_time_zone('America/Chicago').change(hour: 15).change(min: 0)
    evening_end = date.in_time_zone('America/Chicago').end_of_day
    start_time >= morning_end && end_time <= evening_end
  end

  def all_day_off?(date)
    start_time.to_date <= date.to_date && end_time.to_date <= date.to_date && !morning_off?(date) && !evening_off?(date)
  end

  def check_days_taken
    return true unless taken_days.present?



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
      overlapping_day_offs = DayOff.where(
        "DATE(start_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Chicago') <= ? AND
        DATE(end_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Chicago') >= ?", date, date
      )
                                   .where.not(id:) # Exclude the current DayOff instance

      # Check if there are any records found, indicating the day is taken
      overlapping_day_offs.exists?
    end.sort
  end
  # def taken_days
  #   off_dates.select do |date|
  #     overlapping_day_offs = DayOff.where('? BETWEEN start_time AND end_time', date)
  #                                  .where.not(id:) # Assuming 'id' refers to 'self.id'

  #     # Initialize flags for each day
  #     is_morning_off_taken = false
  #     is_evening_off_taken = false

  #     overlapping_day_offs.each do |day_off|
  #       if day_off.all_day_off?(date)
  #         is_morning_off_taken = true
  #         is_evening_off_taken = true
  #         break # All day is taken, no need to check further
  #       end

  #       is_morning_off_taken ||= day_off.morning_off?(date)
  #       is_evening_off_taken ||= day_off.evening_off?(date)
  #     end

  #     # If both morning and evening are taken, consider the day as taken
  #     is_morning_off_taken && is_evening_off_taken
  #   end.sort
  # end

  def available_days
    # Assume `off_dates` is an array of Date objects representing the range from `start_time` to `end_time`.
    available_all_days = off_dates - taken_days

    half_day_available_days = taken_days.select do |date|
      # day_offs_for_date = DayOff.where('? BETWEEN start_time AND end_time', date)
      #                           .where.not(id:)


      morning_off_taken = DayOff.morning_day_offs(date)
      evening_off_taken = DayOff.evening_day_offs(date)
      # Filter out all-day offs and returns days for where only one half is taken
      !DayOff.all_day_offs(date).present? && morning_off_taken != evening_off_taken
    end
    # Combine and uniquify all and half-day available days
    (available_all_days + half_day_available_days).uniq.sort.map do |date|
      day_offs = DayOff.where(
        "DATE(start_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Chicago') <= ? AND
        DATE(end_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Chicago') >= ?", date, date
      )

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
end
