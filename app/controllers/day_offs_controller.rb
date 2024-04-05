class DayOffsController < ApplicationController
  layout 'application'

  def new
    @day_off = DayOff.new
  end

  def create
    @day_off = DayOff.new(day_off_params)

    respond_to do |format|
      if @day_off.taken_days.present?
        # taken_days = @day_off.off_dates.select { |date| DayOff.where(start_time: date).any? }
        debugger
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @day_off.errors, status: :unprocessable_entity }
        format.html do
          render :new, status: :unprocessable_entity, notice: "These days are taken by others, "
        end
      elsif @day_off.save
        format.html { redirect_to meetings_weekly_path(@day_off.start_time), notice: 'Successfully requested day off' }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @day_off.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def destroy; end

  private

  def day_off_params
    params.require(:day_offs).permit(:start_time, :end_time, :user_id)
  end

  def validate_params
    param = params[:day_offs]
    return false if param['start_time'].blank? || param['end_time'].blank? || param['user_id'].blank?

    true
  end
end
