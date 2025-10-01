# frozen_string_literal: true

class LocationsController < ApplicationController
  layout 'application'

  before_action :load_all_locations, :load_all_companies, only: %i[index]
  before_action :load_location, only: %i[edit update destroy]
  before_action :load_company, only: %i[new create]
  before_action :save_return_to, only: %i[index]

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    if @location.save
      LocationUser.create(user_id: current_user.id, location_id: @location.id,
                          role: current_user.admin_user? ? 'admin' : 'user')
      respond_to do |format|
        format.html { redirect_to company_locations_path(@company), status: :see_other, notice: 'Successfully Created' }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors.full_message, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @location.update(location_params)
      respond_to do |format|
        format.html do
          redirect_to company_locations_path(@location.company), status: :see_other, notice: 'Successfully Updated'
        end
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors.full_message, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def index
    # if @locations&.empty?
    #   respond_to do |format|
    #     format.html { redirect_to new_company_location_path }
    #   end
    # else
    render
    # end
  end

  def destroy
    if @location.delete
      respond_to do |format|
        format.html do
          # redirect_to weekly_location_meetings_path(location_id:, start_time: deleted_day_off_start_time),
          redirect_to session[:return_to] || company_locations_path(@location.company),
                      status: :see_other,
                      notice: 'Successfully Deleted'
        end
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html redirect_to(session[:return_to] || root_path), status: :unprocessable_entity, notice: ''
      end
    end
  end

  private

  def load_company
    @company = Company.find(params[:company_id])
  end

  def load_all_companies
    if current_user.developer_user?
      @companies = Company.all
      return
    end
    @companies = current_user.companies.present? ? current_user.companies : current_user.active_working_companies
  end

  def load_all_locations
    load_company
    @locations = @company.locations
  end

  def load_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :street_address,
                                     :ip_address, :company_id, :zip_code, :city,
                                     :country, :state, :building_number)
  end
end
