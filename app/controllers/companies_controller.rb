# frozen_string_literal: true

class CompaniesController < ApplicationController
  layout 'application'

  before_action :load_all_companies, only: %i[index]
  before_action :load_company, only: %i[edit destroy update]
  before_action :save_return_to, only: %i[index]

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        # LocationUser.create()
        format.html do
          redirect_to company_locations_path(@company), status: :see_other, notice: 'Successfully created a company'
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company.errors.full_message, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    if @company.update(company_params)
      respond_to do |format|
        format.turbo_stream do
          redirect_to company_locations_path(@company), status: :see_other, notice: 'Successfully updated'
        end
        # format.html do
        #   redirect_to company_locations_path(@company), notice: 'Successfully updated', status: :see_other
        # end
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def index
    if @companies.empty?
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to new_company_path }
      end
    else
      render
    end
  end

  def destroy
    return unless @company.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end

  private

  def load_all_companies
    @companies = current_user.active_working_companies
  end

  def load_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :user_id)
  end
end
