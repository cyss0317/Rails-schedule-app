# frozen_string_literal: true

class DayOffsController < ApplicationController
  layout 'application'

  before_action :load_day_off, only: %i[edit update destroy]

  def new
    @day_off = DayOff.new
  end

  def create
    @day_off = DayOff.new(day_off_params)

    respond_to do |format|
      if @day_off.save
        format.html do
          redirect_to weekly_location_meetings_path(location_id:, start_date: @day_off.start_time),
                      notice: 'Successfully requested day off'
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @day_off.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    # @day_off.update(day_off_params)
  end

  def update
    if validate_params && @day_off.update(day_off_params)
      respond_to do |format|
        format.html do
          redirect_to weekly_location_meetings_path(location_id:, start_time: @day_off.start_time),
                      notice: 'Successfully updated day off'
        end
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @day_off.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @day_off = DayOff.find(params[:id])
    deleted_day_off_start_time = @day_off.start_time
    @day_off.delete

    respond_to do |format|
      format.html do
        redirect_to weekly_location_meetings_path(location_id:, start_time: deleted_day_off_start_time),
                    notice: 'Successfully deleted day off'
      end
      format.json { head :no_content }
    end
  end

  private

  def day_off_params
    Rails.logger.info("params: #{params}")
    params.require(:day_offs).permit(:start_time, :end_time, :user_id, :description, :location_id)
  end

  def validate_params
    param = params[:day_offs]
    return false if param['start_time'].blank? || param['end_time'].blank? || param['user_id'].blank?

    true
  end

  def load_day_off
    @day_off = DayOff.find(params[:id])
  end

  def location_id
    params[:location_id]
  end
end
