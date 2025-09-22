# frozen_string_literal: true

class LocationsController < ApplicationController
  layout 'application'

  before_action :load_all_locations, :load_all_companies, only: %i[index]
  before_action :load_location, only: %i[edit]
  before_action :load_company, only: %i[new create]

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    if @location.save
      respond_to do |format|
        format.html do
          redirect_to company_locations_path(@company, @location), status: 200, notice: 'Successfully Created'
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

  private

  def load_company
    @company = Company.find(params[:company_id])
  end

  def load_all_companies
    @companies = current_user.companies
  end

  def load_all_locations
    load_company
    @locations = @company.locations
  end

  def load_location
    @location = Loation.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :street_address,
                                     :phone_number, :ip_address, :company_id, :zip_code, :city,
                                     :country, :state, :building_number)
  end
end
