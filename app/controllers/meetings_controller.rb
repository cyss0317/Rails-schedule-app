# frozen_string_literal: true

class MeetingsController < ApplicationController
  helper TimeHelper
  helper DateHelper

  before_action :load_meeting, only: %i[show edit update destroy]
  before_action :select_options_for_users, only: %i[weekly new edit create]

  # GET /meetings or /meetings.json
  def index
    @meetings = Meeting.all.sort_by_start_time
  end

  def weekly
    @meeting = Meeting.new
    Rails.logger.info "ip: #{request.remote_ip}}"
    Rails.logger.info "real ip: #{request.env['HTTP_X_REAL_IP']}}"

    Rails.logger.info "CHOI's house: #{request.remote_ip == ' 72.133.102.178'}}"
    if params[:start_date]
      @start_time = params[:start_date].to_date.beginning_of_week.at_beginning_of_day
      @end_time = params[:start_date].to_date.end_of_week.at_end_of_day
    else
      @start_time = params[:start_time] ? params[:start_time].to_date.beginning_of_week.at_beginning_of_day : DateTime.now.beginning_of_week.at_beginning_of_day
      @end_time = params[:start_time] ? params[:start_time].to_date.end_of_week.at_end_of_day : DateTime.now.end_of_week.at_end_of_day
      # @meetings = Meeting.where(start_time: DateTime.now.beginning_of_week, end_time:DateTime.now.end_of_week)
    end
    @meetings = Meeting.find_all_by_start_time_and_end_time(@start_time, @end_time).sort_by_start_time
    @users = @meetings.map(&:user).uniq
    @users_total_hours_for_week = @users.map do |user|
      total_hours = 0
      @meetings.each do |meeting|
        total_hours += (meeting.end_time - meeting.start_time) / 3600 if meeting.user == user
      end
      [user, total_hours.round(1)]
    end
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
          redirect_to meetings_weekly_path(start_date: @meeting.start_time), notice: 'Meeting was successfully created'
        end
        # format.json { render :show, status: :created, location: @meeting }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /meetings/1 or /meetings/1.json
  def update
    respond_to do |format|
      if @meeting.update(meeting_params)
        format.html do
          redirect_to meetings_weekly_path(start_date: @meeting.start_time), notice: 'Meeting was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @meeting }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meetings/1 or /meetings/1.json
  def destroy
    @meeting.destroy!

    respond_to do |format|
      format.html { redirect_to params[:redirect_url], notice: 'Meeting was successfully destroyed.' }
      # format.html { redirect_back fallback_location: meetings_weekly_path }
      # format.html { redirect_to meetings_url, notice: 'Meeting was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def seed
    Rails.application.load_seed

    redirect_to request.referer
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def load_meeting
    @meeting = Meeting.find(params[:id])
  end

  def select_options_for_users
    start_date = params[:start_date]&.to_date || @meeting&.start_time || DateTime.now.beginning_of_week

    filtered_by_date_day_offs = DayOff.for_day_filtered_by_date(start_date)

    off_users_ids = filtered_by_date_day_offs.map { |off| off.user.id }

    morning_day_off_users_ids = filtered_by_date_day_offs.select do |off|
      off.morning_off?(start_date)
    end.map(&:user_id)

    evening_day_off_users_ids = filtered_by_date_day_offs.select do |off|
      off.evening_off?(start_date)
    end.map(&:user_id)

    unavailable_to_work_employee_ids = off_users_ids - morning_day_off_users_ids - evening_day_off_users_ids

    active_user_ids = User.without_demo_user.sort_by_first_name.select do |user|
      (user.flipper_enabled?(:admin) || user.flipper_enabled?(:active)) && user.id
    end

    filtered_users = User.where(id: active_user_ids)

    return [] if filtered_users.empty?

    @users = if unavailable_to_work_employee_ids.empty?
               filtered_users.pluck(
                 :first_name, :last_name,
                 :id
               ).map do |first_name, last_name, id|
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
             else
               filtered_users.where.not(
                 id: unavailable_to_work_employee_ids
               ).pluck(
                 :first_name, :last_name,
                 :id
               ).map do |first_name, last_name, id|
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
  end

  # Only allow a list of trusted parameters through.
  def meeting_params
    # deserialize_params
    params.require(:meeting).permit(:name, :start_time, :end_time, :user_id)
  end
end
