# frozen_string_literal: true

class CompaniesController < ApplicationController
  layout 'application'

  before_action :load_all_companies, only: %i[index]
  before_action :load_company, only: %i[edit destroy update]

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        # LocationUser.create()
        format.html do
          redirect_to company_locations_path(@company), status: 200, notice: 'Successfully created a company'
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
        # 303
        format.html do
          redirect_to company_locations_path(@company), notice: 'Successfully updated', status: :see_other
        end
        format.turbo_stream { redirect_to company_locations_path(@company), status: :see_other }
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
        format.html { redirect_to new_company_path }
      end
    else
      render
    end
  end

  def destroy
    return unless @company.destroy

    redirect_to root_path
  end

  private

  def load_all_companies
    @companies = current_user.companies
  end

  def load_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :user_id)
  end
end
