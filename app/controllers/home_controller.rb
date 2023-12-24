# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    params.fetch(:start_date, Date.today).to_date
    @meetings = Meeting.default
    current_user ? render : (redirect_to new_user_registration_path)
  end
end
