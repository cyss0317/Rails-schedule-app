# frozen_string_literal: true

class MeetingsController < ApplicationController
  helper TimeHelper
  helper DateHelper

  before_action :set_meeting, only: %i[show edit update destroy]
  before_action :select_options_for_users, only: %i[weekly new]

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
      @start_time = params[:start_time] ? params[:start_time].to_date.beginning_of_week : DateTime.now.beginning_of_week
      @end_time = params[:start_time] ? params[:start_time].to_date.end_of_week : DateTime.now.end_of_week
      # @meetings = Meeting.where(start_time: DateTime.now.beginning_of_week, end_time:DateTime.now.end_of_week)
    end
    @meetings = Meeting.find_all_by_start_time_and_end_time(@start_time, @end_time).sort_by_start_time
  end

  # GET /meetings/1 or /meetings/1.json
  def show; end

  # GET /meetings/new
  def new
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
        format.html { redirect_to meeting_url(@meeting), notice: 'Meeting was successfully updated.' }
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
  def set_meeting
    @meeting = Meeting.find(params[:id])
  end

  def select_options_for_users
    @users = User.all.pluck(:first_name, :last_name, :id).map do |first_name, last_name, id|
      ["#{first_name} #{last_name}", id]
    end
  end

  # Only allow a list of trusted parameters through.
  def meeting_params
    # deserialize_params
    params.require(:meeting).permit(:name, :start_time, :end_time, :user_id)
  end
end
