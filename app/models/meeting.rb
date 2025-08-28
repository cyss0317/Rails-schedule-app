# frozen_string_literal: true

class Meeting < ApplicationRecord
  include ApplicationHelper
  include DateHelper
  include TimeHelper

  belongs_to :user

  validates :start_time, presence: true
  validates :end_time, presence: true, date: { after_or_equal_to: :start_time }

  scope :current_week_meetings, lambda {
                                  where(start_time: Date.today.beginning_of_month.beginning_of_week..Date.today.end_of_month.end_of_week)
                                }
  scope :find_all_by_user_id, ->(user_id) { where(user_id:) }
  scope :monthly_meetings, lambda { |date|
                             where(start_time: date.beginning_of_month.beginning_of_week..date.end_of_month.end_of_week.end_of_day)
                           }
  scope :sort_by_start_time, -> { order(start_time: :asc) }
  scope :within_range, ->(range) { where(start_time: range.first.beginning_of_day..range.last.end_of_day) }
  scope :meetings_for_the_week, lambda { |date|
                                  where(start_time: date.beginning_of_week.beginning_of_day..date.end_of_week.end_of_day)
                                }

  MAX_WIDTH = 80
  HOUR_HEIGHT_IN_PX = 50

  # def self.sort_by_start_time
  #   order(start_time: :asc)
  # end

  def date_range
    Meeting.where(start_time: start_time.beginning_of_week..start_time.end_of_week)
  end

  # write a method to get all the meetings with given start_time and end_time
  def self.find_all_by_start_time_and_end_time(start_time, end_time)
    Meeting.where(start_time: start_time.beginning_of_week..end_time.end_of_week)
  end

  def user_full_name
    user.full_name
  end

  def user_name
    user.first_name
  end

  def user_name_month
    user.name_and_last_name
  end

  def user_weekly_name
    user.name_and_initials
  end

  def user_color
    user.color
  end

  def user_initials
    user[:first_name][0] + user[:last_name][0]
  end

  def str_time_to_date(time)
    if time.is_a? String
      time.to_date
    elsif time.instance_of? Date
      time
    end
  end

  def monthly_shift_hours
    "#{idx_to_time(start_time.hour)}#{start_time.min.zero? ? '' : ":#{start_time.min}"}#{am_pm(start_time)} - #{idx_to_time(end_time.hour)}#{end_time.min.zero? ? '' : ":#{end_time.min}"}#{am_pm(end_time)}"
  end

  def am_pm(time)
    time.hour < 12 ? 'AM' : 'PM'
  end

  def shift_from_to
    time_from_to(start_time, end_time)
  end

  def shift_start_from?(hour)
    start_time.hour == hour
  end

  def shift_belongs_to_hour?(hour)
    return start_time.hour <= hour && start_time.day < end_time.day if end_time.hour.zero?

    start_time.hour <= hour && hour < end_time.hour
  end

  def time_in_am_pm(time)
    "#{time}time.hour < 12 ? 'AM' : 'PM'"
  end

  def morning_shift?
    morning_end = start_time.to_date.in_time_zone('America/Chicago').change(hour: 15).change(min: 0)
    start_time >= start_time.to_date.in_time_zone('America/Chicago').beginning_of_day && (end_time - 1.second) <= morning_end
  end

  def evening_shift?
    morning_end = start_time.to_date.in_time_zone('America/Chicago').change(hour: 15).change(min: 0)
    evening_end = start_time.to_date.in_time_zone('America/Chicago').end_of_day
    (start_time + 1.second) >= morning_end && end_time <= evening_end
  end

  def table_row_height
    (end_time.hour - start_time.hour) * HOUR_HEIGHT_IN_PX + (end_time.min / 60.00).round(2) * HOUR_HEIGHT_IN_PX
  end

  def table_row_top_shift
    (start_time.hour - 8 + (start_time.min / 60.00).round(2)) * HOUR_HEIGHT_IN_PX
    # table_row_top(start_time.hour)
  end

  def table_row_left_shift(idx, meetings_count, hour_idx)
    (idx.to_i % meetings_count) * table_row_width(meetings_count, hour_idx) + table_row_right_spacing(
      meetings_count, idx, hour_idx
    )
  end

  def avoid_overlap(hour_idx, _meetings_count)
    avoid_width_by = 8
    (hour_idx % 3) * avoid_width_by
    # + (meetings_count - 1) * avoid_width_by
  end

  def table_row_right_spacing(meetings_count, idx, hour_idx)
    ((MAX_WIDTH - meetings_count * table_row_width(meetings_count, hour_idx)) / meetings_count) * idx
  end

  def table_row_width(meetings_count, hour_idx)
    MAX_WIDTH / meetings_count - avoid_overlap(hour_idx, meetings_count)
  end

  # def self.current_time_class
  #   DateHelper.current_time_hour
  # end

  def self.morning_shifts; end

  # display work time from to end
  def work_time
    "#{format_date(start_time)}-#{format_date(end_time)}"
  end

  def self.most_recent_week_meetings
    most_recent_meeting = Meeting.last
    week_start_time = most_recent_meeting.start_time.at_beginning_of_week.at_beginning_of_day
    week_end_time = most_recent_meeting.start_time.at_end_of_week.at_end_of_day

    Meeting.where(start_time: week_start_time..week_end_time)
  end

  def self.copy_most_recent_week_of_meetings_to_target_week(target_week, unable_to_copy_meeting_list)
    most_recent_week_meetings = Meeting.most_recent_week_meetings
    target_week_cwday_to_date = {}
    # { 0: date_object }
    target_week.each { |date| target_week_cwday_to_date[date.cwday] = date }

    # [monday, tuesday]
    most_recent_week_meetings.each do |meeting|
      # as we loop over, we want to add day differences to the existing meeting so we can generate
      # same set of meetings for target week
      target_date =  target_week_cwday_to_date[meeting.convert_wday_to_cwday(meeting.start_time.wday)]
      new_start_time = meeting.updated_date_on_start_time(target_date)
      new_end_time = meeting.updated_date_on_end_time(target_date)

      if meeting.user.can_work_for_time_frame?(new_start_time, new_end_time, target_date)
        Meeting.create!(start_time: new_start_time, end_time: new_end_time, user_id: meeting.user_id)
      else
        unable_to_copy_meeting_list << meeting
      end
    end
  end

  def updated_date_on_start_time(target_date)
    DateTime.parse("#{target_date} #{start_time.strftime('%H:%M:%S %z')}")
  end

  def updated_date_on_end_time(target_date)
    DateTime.parse("#{target_date} #{end_time.strftime('%H:%M:%S %z')}")
  end

  def convert_wday_to_cwday(number)
    return 7 if number.zero?

    number
  end

  def user_can_work?
    # check if meetings start_time and end_time collapse with user's day_off's start_time and end_time
  end

  private

  def start_time_cannot_be_greater_than_end_time
    return unless start_time.present? && end_time.present?

    errors.add(:start_time, "can't be greater than end time") if start_time > end_time
  end
end
