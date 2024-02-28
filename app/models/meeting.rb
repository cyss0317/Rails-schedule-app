# frozen_string_literal: true

class Meeting < ApplicationRecord
  include ApplicationHelper
  include DateHelper

  belongs_to :user

  validates :name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :start_time_cannot_be_greater_than_end_time

  scope :find_all_by_user_id, ->(user_id) { where(user_id:) }

  def initializer
    super
  end

  def self.default
    where(start_time: Date.today.beginning_of_month.beginning_of_week..Date.today.end_of_month.end_of_week)
  end

  def self.sort_by_start_time
    order(start_time: :asc)
  end

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

  def morning_shift?
    start_time.hour < 15
  end

  def evening_shift?
    start_time.hour >= 15
  end

  def table_row_height
    (end_time.hour - start_time.hour) * 100 + (end_time.min / 60.00).round(2) * 100
  end

  def table_row_top_shift
    table_row_top(start_time.hour)
  end

  def table_row_left_shift(idx, meetings_count, hour_idx)
    (idx.to_i % meetings_count) * table_row_width(meetings_count) + table_row_right_spacing(
      meetings_count, idx
    ) + avoid_overlap(hour_idx)
  end

  def avoid_overlap(hour_idx)
    (hour_idx + 1) % 3 * 2
  end

  def table_row_right_spacing(meetings_count, idx)
    ((100 - meetings_count * table_row_width(meetings_count)) / meetings_count) * idx
  end

  def table_row_width(meetings_count)
    100 / (meetings_count + 1)
  end

  # def self.current_time_class
  #   DateHelper.current_time_hour
  # end

  def self.morning_shifts; end

  # display work time from to end
  def work_time
    "#{format_date(start_time)}-#{format_date(end_time)}"
  end

  private

  def start_time_cannot_be_greater_than_end_time
    return unless start_time.present? && end_time.present?

    errors.add(:start_time, "can't be greater than end time") if start_time > end_time
  end
end
