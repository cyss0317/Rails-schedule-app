# frozen_string_literal: true

class MeetingsController < ApplicationController
  helper TimeHelper
  helper DateHelper

  before_action :load_meeting, only: %i[show edit update destroy]
  before_action :select_options_for_users, only: %i[weekly new edit create]
  before_action :save_return_to, only: %i[index weekly]

  # GET /meetings or /meetings.json
  def index
    @meetings = Meeting.filter_by_location_id(location_id).sort_by_start_time
  end

  # GET /meetings/1 or /meetings/1.json
  def show; end

  # GET /meetings/new
  def new
    Rails.logger.warn("WARNING: #{params[:start_time]}")
    Rails.logger.warn("WARNING: #{params.inspect}")
    @meeting = Meeting.new

    @start_time = params[:start_time]
  end

  # GET /meetings/1/edit
  def edit; end

  # POST /meetings or /meetings.json
  def create # rubocop:disable Metrics/MethodLength
    @meeting = Meeting.new(meeting_params)
    respond_to do |format|
      if @meeting.save
        # format.html { redirect_to meeting_url(@meeting), notice: 'Meeting was successfully created.' }
        format.html do
          redirect_to weekly_location_meetings_path(location_id: @meeting.location_id, start_date: @meeting.start_time.beginning_of_day.to_date),
                      notice: 'Meeting was successfully created'
        end
        # format.json { render :show, status: :created, location: @meeting }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @meeting.update(meeting_params)
      respond_to do |format|
        format.html do
          redirect_to weekly_location_meetings_path(location_id: @meeting.location_id, start_date: @meeting.start_time.beginning_of_day.to_date),
                      notice: 'Meeting was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @meeting }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meetings/1 or /meetings/1.json
  def destroy
    return_to_url = weekly_location_meetings_path(location_id: @meeting.location_id, start_time: @meeting.start_time.beginning_of_day.to_date )
    @meeting.destroy!

    respond_to do |format|
      format.html { redirect_to session.delete(:return_to) || return_to_url, notice: 'Meeting was successfully destroyed.' }
      # format.html { redirect_back fallback_location: meetings_weekly_path }
      # format.html { redirect_to meetings_url, notice: 'Meeting was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def seed
    Rails.application.load_seed

    redirect_to request.referer
  end

  def weekly
    @meeting = Meeting.new
    Rails.logger.info "ip: #{request.remote_ip}}"
    Rails.logger.info "real ip: #{request.env['HTTP_X_REAL_IP']}}"
    if params[:start_date]
      @start_time = params[:start_date].to_date.beginning_of_week.at_beginning_of_day
      @end_time = params[:start_date].to_date.end_of_week.at_end_of_day
    else
      @start_time = params[:start_time] ? params[:start_time].to_date.beginning_of_week.at_beginning_of_day : DateTime.now.beginning_of_week.at_beginning_of_day
      @end_time = params[:start_time] ? params[:start_time].to_date.end_of_week.at_end_of_day : DateTime.now.end_of_week.at_end_of_day
      # @meetings = Meeting.where(start_time: DateTime.now.beginning_of_week, end_time:DateTime.now.end_of_week)
    end
    @meetings = Meeting.filter_by_location_id(location_id).find_all_by_start_time_and_end_time(@start_time,
                                                                                               @end_time).sort_by_start_time
    @location_id = location_id
    @day_offs = DayOff.filter_by_location_id(location_id)
    @users = @meetings.map(&:user).uniq
    @users_total_hours_for_week = @users.map do |user|
      total_hours = 0
      @meetings.each do |meeting|
        total_hours += (meeting.end_time - meeting.start_time) / 3600 if meeting.user == user
      end
      [user, total_hours.round(1)]
    end
  end

  def monthly
    Rails.logger.info "ip address: #{request.remote_ip}"
    Rails.logger.info "X-Forwarded-For: #{request.headers['X-Forwarded-For']}"
    Rails.logger.info "HTTP_X_REAL_IP: #{request.headers['HTTP_X_REAL_IP']}"

    start_date = params.fetch(:start_date, Date.today).to_date
    @location_id = location_id
    @meetings =  Meeting.filter_by_location_id(location_id).monthly_meetings(start_date)

    @day_offs = DayOff.filter_by_location_id(location_id)
    render
  end

  def copy_previous_week_schedule
    @unable_to_copy_meeting_list = []
    # params should have selected week
    target_week = convert_target_week_param
    # grab the most recent meeting and scope them by the week
    meetings = Meeting.copy_most_recent_week_of_meetings_to_target_week(target_week, @unable_to_copy_meeting_list,
                                                                        location_id)

    notice_message = if meetings.present?
                       @unable_to_copy_meeting_list.map do |meeting|
                         "Failed to create for #{meeting.user.name_and_last_name}, #{meeting.start_time.to_date}"
                       end.join('<br>').html_safe
                     else
                       'There are no previous schedules to copy'
                     end

    redirect_to weekly_location_meetings_path(start_date: target_week[0]), notice: notice_message
  end

  def clear_selected_week
    target_week = convert_target_week_param
    target_week_range = target_week.first.beginning_of_day..target_week.last.end_of_day

    meetings = Meeting.filter_by_location_id(location_id).within_range(target_week_range)
    Rails.cache.write('last_cleared_schedules', meetings, expires_in: 10.minutes)

    if meetings.exists?
      meetings.destroy_all
      notice_message = ['Successfully deleted']
    else
      notice_message = ['There are no schedules for this week']
    end

    Rails.logger.info("CACHED: #{Rails.cache.read('last_cleared_schedules')}")
    redirect_to weekly_location_meetings_path(start_date: target_week[0]), notice: notice_message
  end

  def location_id
    params[:location_id]
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def load_meeting
    @meeting = Meeting.find(params[:id])
  end

  def select_options_for_users
    start_date = params[:start_date]&.to_date || @meeting&.start_time || DateTime.now.beginning_of_week

    day_offs_filtered_by_date = DayOff.filter_by_location_id(location_id).for_day_filtered_by_date(start_date)

    off_users_ids = day_offs_filtered_by_date.map { |off| off.user.id }

    morning_day_off_users_ids = day_offs_filtered_by_date.select do |off|
      off.morning_off?(start_date)
    end.map(&:user_id)

    evening_day_off_users_ids = day_offs_filtered_by_date.select do |off|
      off.evening_off?(start_date)
    end.map(&:user_id)

    unavailable_to_work_employee_ids = off_users_ids - morning_day_off_users_ids - evening_day_off_users_ids

    filtered_users =   User.joins(:location_users).where(location_users: { location_id:,
                                                                           active: true }).without_demo_user.sort_by_first_name
    return @users = [] if filtered_users.empty?

    @users = if unavailable_to_work_employee_ids.empty?
               filtered_users.pluck(
                 :first_name, :last_name,
                 :id
               ).map do |first_name, last_name, id|
                 availability_label(first_name, last_name, id,
                                    morning_day_off_users_ids, evening_day_off_users_ids)
               end
             else
               filtered_users.where.not(
                 id: unavailable_to_work_employee_ids
               ).pluck(
                 :first_name, :last_name,
                 :id
               ).map do |first_name, last_name, id|
                 availability_label(first_name, last_name, id,
                                    morning_day_off_users_ids, evening_day_off_users_ids)
               end

             end
  end

  # Only allow a list of trusted parameters through.
  def meeting_params
    # deserialize_params
    params.require(:meeting).permit(:name, :start_time, :end_time, :user_id, :location_id)
  end

  def convert_target_week_param
    params[:target_week].map { |date| Date.parse(date) }
  end

  def availability_label(first_name, last_name, id, morning_day_off_users_ids, evening_day_off_users_ids)
    if morning_day_off_users_ids&.include?(id)
      [
        "#{first_name} #{last_name}, Off 9AM - 3PM", id
      ]
    elsif evening_day_off_users_ids&.include?(id)
      [
        "#{first_name} #{last_name}, Off 3PM - 8PM", id
      ]
    else
      [
        "#{first_name} #{last_name}", id
      ]
    end
  end
end
