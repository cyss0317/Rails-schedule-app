# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    # @meetings = Meeting.find_all_by_user_id(current_user.id)
    # Scope your query to the dates being shown:
    start_date = params.fetch(:start_date, Date.today).to_date
    @meetings = Meeting.where(start_time: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week) 
    current_user ? render : (redirect_to new_user_registration_path)
  end
end
